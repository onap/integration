package check

// Informer collects and returns information on cluster.
type Informer interface {
	// GetAPIParams returns API server parameters.
	GetAPIParams() ([]string, error)
}

// Command represents commands run on cluster.
type Command int

const (
	// APIProcess represents API server command.
	APIProcess Command = iota
)

func (c Command) String() string {
	names := [...]string{
		"kube-apiserver",
	}

	if c < APIProcess || c > APIProcess {
		return "exit"
	}
	return names[c]
}
