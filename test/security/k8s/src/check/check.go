package check

// Informer collects and returns information on cluster.
type Informer interface {
	// GetAPIParams returns API server parameters.
	GetAPIParams() ([]string, error)
}

// Command represents commands run on cluster.
type Command int

const (
	// APIProcess represents API server command ("kube-apiserver").
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

// Service represents services run on Rancher-based cluster.
type Service int

const (
	// APIService represents API server service ("kubernetes/kubernetes").
	APIService Service = iota
)

func (s Service) String() string {
	names := [...]string{
		"kubernetes/kubernetes",
	}

	if s < APIService || s > APIService {
		return ""
	}
	return names[s]
}
