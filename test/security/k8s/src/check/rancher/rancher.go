// Package rancher wraps Rancher commands necessary for K8s inspection.
package rancher

import (
	"bytes"
	"fmt"
	"os/exec"

	"check"
)

const (
	bin                      = "rancher"
	paramHost                = "--host"
	cmdHosts                 = "hosts"
	cmdHostsParams           = "--quiet"
	cmdDocker                = "docker"
	cmdDockerCmdPs           = "ps"
	cmdDockerCmdPsParams     = "--no-trunc"
	cmdDockerCmdPsFilter     = "--filter"
	cmdDockerCmdPsFilterArgs = "label=io.rancher.stack_service.name="
	cmdDockerCmdPsFormat     = "--format"
	cmdDockerCmdPsFormatArgs = "{{.Command}}"
)

// Rancher implements Informer interface.
type Rancher struct {
	check.Informer
}

// GetAPIParams returns parameters of running Kubernetes API server.
// It queries default environment set in configuration file.
func (r *Rancher) GetAPIParams() ([]string, error) {
	return getProcessParams(check.APIProcess, check.APIService)
}

// GetSchedulerParams returns parameters of running Kubernetes scheduler.
// It queries default environment set in configuration file.
func (r *Rancher) GetSchedulerParams() ([]string, error) {
	return getProcessParams(check.SchedulerProcess, check.SchedulerService)
}

// GetControllerManagerParams returns parameters of running Kubernetes scheduler.
// It queries default environment set in configuration file.
func (r *Rancher) GetControllerManagerParams() ([]string, error) {
	return getProcessParams(check.ControllerManagerProcess, check.ControllerManagerService)
}

// GetEtcdParams returns parameters of running etcd.
// It queries only cluster nodes with "controlplane" role.
func (r *Rancher) GetEtcdParams() ([]string, error) {
	return []string{}, check.ErrNotImplemented
}

func getProcessParams(process check.Command, service check.Service) ([]string, error) {
	hosts, err := listHosts()
	if err != nil {
		return []string{}, err
	}

	for _, host := range hosts {
		cmd, err := getPsCmdOutput(host, service)
		if err != nil {
			return []string{}, err
		}

		cmd = trimOutput(cmd) // TODO: improve `docker ps` query format.
		if len(cmd) > 0 {
			i := bytes.Index(cmd, []byte(process.String()))
			if i == -1 {
				return []string{}, fmt.Errorf("missing %s command", process)
			}
			return btos(cmd[i+len(process.String()):]), nil
		}
	}
	return []string{}, nil
}

// listHosts lists IDs of active hosts.
// It queries default environment set in configuration file.
func listHosts() ([]string, error) {
	cmd := exec.Command(bin, cmdHosts, cmdHostsParams)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	return btos(out), nil
}

// getPsCmdOutput returns running Kubernetes service command with its parameters.
// It queries default environment set in configuration file.
func getPsCmdOutput(host string, service check.Service) ([]byte, error) {
	// Following is equivalent to:
	// $ rancher --host $HOST \
	//   docker ps --no-trunc \
	//   --filter "label=io.rancher.stack_service.name=$SERVICE" \
	//   --format "{{.Command}}"
	cmd := exec.Command(bin, paramHost, host,
		cmdDocker, cmdDockerCmdPs, cmdDockerCmdPsParams,
		cmdDockerCmdPsFilter, cmdDockerCmdPsFilterArgs+service.String(),
		cmdDockerCmdPsFormat, cmdDockerCmdPsFormatArgs)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	return out, nil
}

// trimOutput removes trailing new line and brackets from output.
func trimOutput(b []byte) []byte {
	b = bytes.TrimSpace(b)
	b = bytes.TrimPrefix(b, []byte("["))
	b = bytes.TrimSuffix(b, []byte("]"))
	return b
}

// btos converts slice of bytes to slice of strings split by white space characters.
func btos(in []byte) []string {
	var out []string
	for _, b := range bytes.Fields(in) {
		out = append(out, string(b))
	}
	return out
}
