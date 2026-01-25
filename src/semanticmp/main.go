package main

import (
	"context"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"sort"
	"strings"

	gcmp "github.com/google/go-cmp/cmp"
	"github.com/spf13/cobra"
	machineryaml "k8s.io/apimachinery/pkg/util/yaml"
	"sigs.k8s.io/yaml"
)

const readBufSize = 1024 * 1024

func ensureSameKind(a, b string) error {
	info := func(target string) (bool, bool, error) {
		fi, err := os.Stat(target)
		if err != nil {
			return false, false, err
		}
		return fi.IsDir(), !fi.IsDir(), nil
	}
	aIsDir, aIsFile, aErr := info(a)
	if aErr != nil {
		return aErr
	}
	bIsDir, bIsFile, bErr := info(a)
	if bErr != nil {
		return bErr
	}

	if aIsDir != bIsDir || aIsFile != bIsFile {
		return fmt.Errorf("%s and %s not of the same type", a, b)
	}

	return nil
}

func toYaml(o interface{}) (string, error) {
	objects := make([]interface{}, 0)
	oo, ok := o.([]interface{})
	if ok {
		objects = oo
	} else {
		objects = append(objects, o)
	}
	yamls := make([]string, 0, len(objects))
	for i := range objects {
		yamlBytes, err := yaml.Marshal(objects[i])
		if err != nil {
			return "", err
		}
		yamls = append(yamls, string(yamlBytes))
	}
	return strings.Join(yamls, "---\n"), nil
}

type differ interface {
	Diff(ctx context.Context, aFile, bFile string, a, b interface{}) error
}

type yamlDiffer struct{}

func (sd *yamlDiffer) Diff(_ context.Context, aFile, bFile string, a, b interface{}) error {
	aYaml, err := toYaml(a)
	if err != nil {
		return err
	}
	bYaml, err := toYaml(b)
	if err != nil {
		return err
	}
	if diff := gcmp.Diff(string(aYaml), string(bYaml)); diff != "" {
		fmt.Printf("* %s\n* %s\n%s\n\n", a, b, diff)
	}
	return nil
}

type yamlMultidocsDiffer struct{}

func (sd *yamlMultidocsDiffer) Diff(_ context.Context, aFile, bFile string, a, b interface{}) error {
	toYamls := func(o interface{}) ([]string, error) {
		objects := make([]interface{}, 0)
		oo, ok := o.([]interface{})
		if ok {
			objects = oo
		} else {
			objects = append(objects, o)
		}
		yamls := make([]string, 0, len(objects))
		for i := range objects {
			yamlBytes, err := yaml.Marshal(objects[i])
			if err != nil {
				return nil, err
			}
			yamls = append(yamls, string(yamlBytes))
		}
		return yamls, nil
	}
	aYamls, err := toYamls(a)
	if err != nil {
		return err
	}
	bYamls, err := toYamls(b)
	if err != nil {
		return err
	}

	maxLen := len(aYamls)
	if len(bYamls) > maxLen {
		maxLen = len(bYamls)
	}
	i := 0
	diffs := ""
	for i < maxLen {
		aa, bb := "", ""
		if i < len(bYamls) {
			bb = bYamls[i]
		}
		if i < len(aYamls) {
			aa = aYamls[i]
		}
		diff := gcmp.Diff(aa, bb)
		if diff != "" {
			diffs += fmt.Sprintf("* object[%d]:\n", i)
			diffs += diff + "\n"
		}
		i += 1
	}
	if diffs != "" {
		fmt.Printf("* %s\n* %s\n%s\n\n", a, b, diffs)
	}
	return nil
}

type meldDiffer struct{}

func (sd *meldDiffer) Diff(ctx context.Context, aFile, bFile string, a, b interface{}) error {
	aYaml, err := toYaml(a)
	if err != nil {
		return err
	}
	bYaml, err := toYaml(b)
	if err != nil {
		return err
	}

	create := func(prefix, filename, data string) (string, error) {
		f, err := os.CreateTemp("/tmp", fmt.Sprintf(prefix, filename))
		if err != nil {
			return "", fmt.Errorf("create temp: %w", err)
		}
		_, err = f.WriteString(data)
		if err != nil {
			return "", fmt.Errorf("write: %w", err)
		}
		return f.Name(), f.Close()
	}

	aPath, err := create("semcmp-%s-left-*", path.Base(aFile), aYaml)
	if err != nil {
		return err
	}
	bPath, err := create("semcmp-%s-right-*", path.Base(bFile), bYaml)
	if err != nil {
		return err
	}

	cmd := exec.CommandContext(ctx, "meld", aPath, bPath)
	outBytes, err := cmd.CombinedOutput()
	fmt.Printf("%s", outBytes)
	if err != nil {
		return err
	}

	if err := os.Remove(aPath); err != nil {
		return err
	}
	return os.Remove(bPath)
}

type diffDiffer struct{}

func (sd *diffDiffer) Diff(ctx context.Context, aFile, bFile string, a, b interface{}) error {
	aYaml, err := toYaml(a)
	if err != nil {
		return err
	}
	bYaml, err := toYaml(b)
	if err != nil {
		return err
	}

	create := func(prefix, filename, data string) (string, error) {
		f, err := os.CreateTemp("/tmp", fmt.Sprintf(prefix, filename))
		if err != nil {
			return "", fmt.Errorf("create temp: %w", err)
		}
		_, err = f.WriteString(data)
		if err != nil {
			return "", fmt.Errorf("write: %w", err)
		}
		return f.Name(), f.Close()
	}

	aPath, err := create("semcmp-%s-left-*", path.Base(aFile), aYaml)
	if err != nil {
		return err
	}
	bPath, err := create("semcmp-%s-right-*", path.Base(bFile), bYaml)
	if err != nil {
		return err
	}

	cmd := exec.CommandContext(ctx, "diff", aPath, bPath)
	outBytes, err := cmd.CombinedOutput()
	fmt.Printf("\n***\n*** %s\n***\n", path.Base(aFile))
	fmt.Printf("%s", outBytes)
	if err != nil && cmd.ProcessState.ExitCode() == 2 {
		return err
	}

	if err := os.Remove(aPath); err != nil {
		return err
	}
	return os.Remove(bPath)
}

type comparer struct {
	dfer differ
}

func (d *comparer) cmp(ctx context.Context, a, b string) error {
	aInfo, err := os.Stat(a)
	if err != nil {
		return err
	}
	if aInfo.IsDir() {
		return d.cmpDir(ctx, a, b)
	}
	return d.cmpFile(ctx, a, b)
}

func (c *comparer) cmpDir(ctx context.Context, a, b string) error {
	files := func(f string) ([]string, error) {
		ff := make([]string, 0)
		if err := filepath.WalkDir(f, func(p string, d fs.DirEntry, err error) error {
			if d.IsDir() {
				return nil
			}
			if filepath.Ext(d.Name()) != ".yaml" {
				return nil
			}
			ff = append(ff, d.Name())
			return nil
		}); err != nil {
			return nil, err
		}
		sort.Slice(ff, func(i, j int) bool { return strings.Compare(ff[i], ff[j]) <= 0 })
		return ff, nil
	}

	aFiles, err := files(a)
	if err != nil {
		return err
	}
	bFiles, err := files(b)
	if err != nil {
		return err
	}

	aIdx, bIdx := 0, 0
	for aIdx < len(aFiles) {
		if bIdx >= len(bFiles) {
			break
		}
		aa, bb := aFiles[aIdx], bFiles[bIdx]
		cc := strings.Compare(aa, bb)
		switch cc {
		case -1:
			fmt.Printf("%s not matched\n\n", bb)
			aIdx += 1
		case 0:
			if err := c.cmpFile(ctx, path.Join(a, aa), path.Join(b, bb)); err != nil {
				return err
			}
			aIdx += 1
			bIdx += 1
		default:
			fmt.Printf("%s not matched\n\n", aa)
			bIdx += 1
		}
	}

	for bIdx < len(bFiles) {
		fmt.Printf("%s not matched\n\n", bFiles[bIdx])
		bIdx += 1
	}
	for aIdx < len(aFiles) {
		fmt.Printf("%s not matched\n\n", aFiles[aIdx])
		aIdx += 1
	}

	return nil
}

func (c *comparer) cmpFile(ctx context.Context, a, b string) error {
	toObjs := func(f string) (interface{}, error) {
		objs := make([]interface{}, 0)
		bytes, err := os.ReadFile(f)
		if err != nil {
			return nil, fmt.Errorf("read %s: %w", f, err)
		}
		bytesReader := io.NopCloser(strings.NewReader(string(bytes)))
		docReader := machineryaml.NewDocumentDecoder(bytesReader)
		isEOF := false
		for {
			rBytes := make([]byte, readBufSize)
			n, err := docReader.Read(rBytes)
			if err != nil {
				if err == io.EOF {
					isEOF = true
				} else {
					return nil, fmt.Errorf("read doc %s: %w", f, err)
				}
			}
			if n > 0 {
				rBytes = rBytes[0:n]
				obj := make(map[string]interface{}, 0)
				err = yaml.Unmarshal(rBytes, &obj)
				if err != nil {
					return nil, fmt.Errorf("unmarshal %s: %w", f, err)
				}
				objs = append(objs, obj)
			}
			if isEOF {
				break
			}
		}
		return objs, nil
	}

	aObjs, err := toObjs(a)
	if err != nil {
		return err
	}
	bObjs, err := toObjs(b)
	if err != nil {
		return err
	}

	return c.dfer.Diff(ctx, a, b, aObjs, bObjs)
}

type options struct {
	differ string
}

func main() {
	opts := options{}
	cmd := cobra.Command{
		Use:   "semcmp [target-a] [target-b]",
		Short: "Diff yaml files and folder",
		RunE: func(cmd *cobra.Command, args []string) error {
			if len(args) != 2 {
				return cmd.Help()
			}

			a := args[0]
			b := args[1]
			if err := ensureSameKind(a, b); err != nil {
				return fmt.Errorf("ensure same kind: %w", err)
			}

			var dfer differ
			switch opts.differ {
			case "diff":
				dfer = &diffDiffer{}
			case "yaml":
				dfer = &yamlDiffer{}
			case "yaml-multi":
				dfer = &yamlMultidocsDiffer{}
			case "meld":
			default:
				dfer = &meldDiffer{}
			}

			d := comparer{dfer: dfer}
			if err := d.cmp(cmd.Context(), a, b); err != nil {
				fmt.Printf("%s\n", err)
				os.Exit(1)
			}

			return nil
		},
	}

	cmd.SilenceUsage = true
	cmd.PersistentFlags().StringVar(&opts.differ, "diff", "", "Diff strategy: diff, yaml, yaml-multi, meld. Default to meld.")

	if err := cmd.ExecuteContext(context.Background()); err != nil {
		fmt.Printf("%s\n", err)
		os.Exit(1)
	}
}
