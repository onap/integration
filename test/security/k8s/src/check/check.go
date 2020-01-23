package check

// Informer collects and returns information on cluster.
type Informer interface {
	// GetAPIParams returns API server parameters.
	GetAPIParams() ([]string, error)
	// GetSchedulerParams returns scheduler parameters.
	GetSchedulerParams() ([]string, error)
	// GetControllerManagerParams returns controller manager parameters.
	GetControllerManagerParams() ([]string, error)
	// GetEtcdParams returns etcd parameters.
	GetEtcdParams() ([]string, error)
}

// Command represents commands run on cluster.
type Command int

const (
	// APIProcess represents API server command ("kube-apiserver").
	APIProcess Command = iota
	// SchedulerProcess represents scheduler command ("kube-scheduler").
	SchedulerProcess
	// ControllerManagerProcess represents controller manager command ("kube-controller-manager").
	ControllerManagerProcess
	// EtcdProcess represents controller manager service ("etcd").
	EtcdProcess
)

func (c Command) String() string {
	names := [...]string{
		"kube-apiserver",
		"kube-scheduler",
		"kube-controller-manager",
		"etcd",
	}

	if c < APIProcess || c > EtcdProcess {
		return "exit"
	}
	return names[c]
}
