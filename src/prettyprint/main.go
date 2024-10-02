package main

import (
	"errors"
	"fmt"
	"io"
	"os"
	"strings"

	"sigs.k8s.io/yaml"
)

func prettyPrint(o interface{}, indentLvl int) ([]string, error) {
	out := make([]string, 0)
	writeLine := func(data string) { out = append(out, data) }
	switch o.(type) {
	case nil:
		return []string{"nil"}, nil
	case bool:
		bb := o.(bool)
		return []string{fmt.Sprintf("%t", bb)}, nil
	case string:
		ss := o.(string)
		ss = strings.ReplaceAll(ss, `"`, `\"`)
		ss = strings.ReplaceAll(ss, `\`, `\\`)
		return []string{fmt.Sprintf("\"%s\"", ss)}, nil
	case float32:
		ff := o.(float32)
		return []string{fmt.Sprintf("%g", ff)}, nil
	case float64:
		ff := o.(float64)
		return []string{fmt.Sprintf("%g", ff)}, nil
	case complex64:
		ff := o.(complex64)
		return []string{fmt.Sprintf("%g", ff)}, nil
	case complex128:
		ff := o.(complex128)
		return []string{fmt.Sprintf("%g", ff)}, nil
	case int:
		ii := o.(int)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case int8:
		ii := o.(int8)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case int16:
		ii := o.(int16)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case int32:
		ii := o.(int32)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case int64:
		ii := o.(int64)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case uint:
		ii := o.(uint)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case uint8:
		ii := o.(uint8)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case uint16:
		ii := o.(uint16)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case uint32:
		ii := o.(uint32)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case uint64:
		ii := o.(uint64)
		return []string{fmt.Sprintf("%d", ii)}, nil
	case map[string]interface{}:
		mmap := o.(map[string]interface{})
		writeLine("map[string]interface{}{\n")
		for k := range mmap {
			ppMap, err := prettyPrint(mmap[k], indentLvl)
			if err != nil {
				return nil, err
			}
			if len(ppMap) > 0 {
				ppMap[len(ppMap)-1] += ",\n"
			}
			for i := range ppMap {
				ppMapEntry := ppMap[i]
				if i == 0 {
					keyAndEntry := fmt.Sprintf("\"%s\":", k) + " " + ppMapEntry
					writeLine(indent(keyAndEntry, indentLvl+4))
				} else {
					writeLine(indent(ppMapEntry, indentLvl+4))
				}
			}
		}
		writeLine(indent("}", indentLvl))
	case []interface{}:
		slice := o.([]interface{})
		writeLine("[]interface{}{\n")
		for i := range slice {
			ppSlice, err := prettyPrint(slice[i], indentLvl)
			if err != nil {
				return nil, err
			}
			if len(ppSlice) > 0 {
				ppSlice[len(ppSlice)-1] += ",\n"
			}
			for j := range ppSlice {
				ppSliceEntry := ppSlice[j]
				writeLine(indent(ppSliceEntry, indentLvl+4))
			}
		}
		writeLine(indent("}", indentLvl))
	default:
		return nil, fmt.Errorf("unsupported type %T", o)
	}
	return out, nil
}

func indent(data string, n int) string {
	spaces := ""
	for i := 0; i < n; i++ {
		spaces += " "
	}
	return spaces + data
}

func printManifests(manifests []byte) (string, error) {
	out := make([]string, 0)
	writeLine := func(data string) { out = append(out, data) }
	manifestsSplit := strings.Split(string(manifests), "---")
	if len(manifestsSplit) == 0 {
		return "// No manifests", nil
	}
	writeLine("[]interface{}{\n")
	for _, manifest := range manifestsSplit {
		obj := make(map[string]interface{})
		if err := yaml.Unmarshal([]byte(manifest), &obj); err != nil {
			return "", fmt.Errorf("unmarshal: %w", err)
		}
		lines, err := prettyPrint(obj, 0)
		if err != nil {
			return "", fmt.Errorf("pretty print: %w", err)
		}
		for i, line := range lines {
			if i < len(lines)-1 {
				writeLine(indent(line, 4))
			} else {
				writeLine(indent(line+",", 4))
			}
		}
		writeLine("\n")
	}
	writeLine("}\n")
	return strings.Join(out, ""), nil
}

func readData(args []string) ([]byte, error) {
	switch len(args) {
	case 1:
		return io.ReadAll(os.Stdin)
	case 2:
		return os.ReadFile(args[1])
	default:
		return nil, errors.New("path to yaml is required or read from stdin")
	}
}

func main() {
	data, err := readData(os.Args)
	if err != nil {
		fmt.Printf("read data: %s", err)
		os.Exit(1)
	}
	pp, err := printManifests(data)
	if err != nil {
		fmt.Printf("print manifests: %s", err)
		os.Exit(1)
	}
	fmt.Printf("%s", pp)
}
