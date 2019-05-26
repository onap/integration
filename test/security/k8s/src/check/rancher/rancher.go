// Package rancher wraps Rancher commands necessary for K8s inspection.
package rancher

import (
	"bytes"
	"errors"
	"os/exec"
)

const (
	path                     = "/usr/local/bin/rancher"
	paramHost                = "--host"
	cmdHosts                 = "hosts"
	cmdHostsParams           = "--quiet"
	cmdDocker                = "docker"
	cmdDockerCmdPs           = "ps"
	cmdDockerCmdPsParams     = "--no-trunc"
	cmdDockerCmdPsFilter     = "--filter"
	cmdDockerCmdPsFilterArgs = "label=io.rancher.stack_service.name=kubernetes/kubernetes"
	cmdDockerCmdPsFormat     = "--format"
	cmdDockerCmdPsFormatArgs = "{{.Command}}"
	k8sProcess               = "kube-apiserver"
)

// GetK8sParams returns parameters of running Kubernetes API server.
// It queries default environment set in configuration file.
func GetK8sParams() ([]string, error) {
	hosts, err := listHosts()
	if err != nil {
		return []string{}, err
	}

	for _, host := range hosts {
		cmd, err := getK8sCmd(host)
		if err != nil {
			return []string{}, err
		}

		if len(cmd) > 0 {
			i := bytes.Index(cmd, []byte(k8sProcess))
			if i == -1 {
				return []string{}, errors.New("missing " + k8sProcess + " command")
			}
			return btos(cmd[i+len(k8sProcess):]), nil
		}
	}
	return []string{}, nil
}

// listHosts lists IDs of active hosts.
// It queries default environment set in configuration file.
func listHosts() ([]string, error) {
	cmd := exec.Command(path, cmdHosts, cmdHostsParams)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	return btos(out), nil
}

// getK8sCmd returns running Kubernetes API server command with its parameters.
// It queries default environment set in configuration file.
func getK8sCmd(host string) ([]byte, error) {
	// Following is equivalent to:
	// $ rancher --host $HOST \
	//   docker ps --no-trunc \
	//   --filter "label=io.rancher.stack_service.name=kubernetes/kubernetes" \
	//   --format "{{.Command}}"
	cmd := exec.Command(path, paramHost, host,
		cmdDocker, cmdDockerCmdPs, cmdDockerCmdPsParams,
		cmdDockerCmdPsFilter, cmdDockerCmdPsFilterArgs,
		cmdDockerCmdPsFormat, cmdDockerCmdPsFormatArgs)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	return out, nil
}

// btos converts slice of bytes to slice of strings split by white space characters.
func btos(in []byte) []string {
	var out []string
	for _, b := range bytes.Fields(in) {
		out = append(out, string(b))
	}
	return out
}
