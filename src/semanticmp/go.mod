module github.com/danilo-gemoli/semcmp

go 1.22.4

require (
	github.com/google/go-cmp v0.6.0
	sigs.k8s.io/yaml v1.4.0
)

require k8s.io/apimachinery v0.31.1

require (
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/spf13/cobra v1.8.1 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	golang.org/x/sync v0.8.0 // indirect
	sigs.k8s.io/json v0.0.0-20221116044647-bc3834ca7abd // indirect
)

replace github.com/google/go-cmp => /home/dgemoli/dev/src/github.com/google/go-cmp
