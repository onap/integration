package check

// Informer collects and returns information on cluster.
type Informer interface {
	// GetAPIParams returns API server parameters.
	GetAPIParams() ([]string, error)
	// GetSchedulerParams returns scheduler parameters.
	GetSchedulerParams() ([]string, error)
}

// Command represents commands run on cluster.
type Command int

const (
	// APIProcess represents API server command ("kube-apiserver").
	APIProcess Command = iota
	// SchedulerProcess represents scheduler command ("kube-scheduler").
	SchedulerProcess
)

func (c Command) String() string {
	names := [...]string{
		"kube-apiserver",
		"kube-scheduler",
	}

	if c < APIProcess || c > SchedulerProcess {
		return "exit"
	}
	return names[c]
}

// Service represents services run on Rancher-based cluster.
type Service int

const (
	// APIService represents API server service ("kubernetes/kubernetes").
	APIService Service = iota
	// SchedulerService represents scheduler service ("kubernetes/scheduler").
	SchedulerService
)

func (s Service) String() string {
	names := [...]string{
		"kubernetes/kubernetes",
		"kubernetes/scheduler",
	}

	if s < APIService || s > SchedulerService {
		return ""
	}
	return names[s]
}
