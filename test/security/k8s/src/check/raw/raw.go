// Package raw wraps SSH commands necessary for K8s inspection.
package raw

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os/user"
	"path/filepath"

	"golang.org/x/crypto/ssh"
	kh "golang.org/x/crypto/ssh/knownhosts"

	"check"
	"check/config"
)

const (
	controlplane = "controlplane"
	etcd         = "etcd"
	worker       = "worker"

	knownHostsFile = "~/.ssh/known_hosts"
)

// Raw implements Informer interface.
type Raw struct {
	check.Informer
}

// GetAPIParams returns parameters of running Kubernetes API servers.
// It queries only cluster nodes with "controlplane" role.
func (r *Raw) GetAPIParams() ([]string, error) {
	return getProcessParams(check.APIProcess)
}

// GetSchedulerParams returns parameters of running Kubernetes scheduler.
// It queries only cluster nodes with "controlplane" role.
func (r *Raw) GetSchedulerParams() ([]string, error) {
	return getProcessParams(check.SchedulerProcess)
}

// GetControllerManagerParams returns parameters of running Kubernetes scheduler.
// It queries only cluster nodes with "controlplane" role.
func (r *Raw) GetControllerManagerParams() ([]string, error) {
	return getProcessParams(check.ControllerManagerProcess)
}

// GetEtcdParams returns parameters of running etcd.
// It queries only cluster nodes with "controlplane" role.
func (r *Raw) GetEtcdParams() ([]string, error) {
	return []string{}, check.ErrNotImplemented
}

func getProcessParams(process check.Command) ([]string, error) {
	nodes, err := config.GetNodesInfo()
	if err != nil {
		return []string{}, err
	}

	for _, node := range nodes {
		if isControlplaneNode(node.Role) {
			cmd, err := getInspectCmdOutput(node, process)
			if err != nil {
				return []string{}, err
			}

			cmd = trimOutput(cmd) // TODO: improve `docker inspect` query format.
			if len(cmd) > 0 {
				i := bytes.Index(cmd, []byte(process.String()))
				if i == -1 {
					return []string{}, fmt.Errorf("missing %s command", process)
				}
				return btos(cmd[i+len(process.String()):]), nil
			}
		}
	}

	return []string{}, nil
}

func isControlplaneNode(roles []string) bool {
	for _, role := range roles {
		if role == controlplane {
			return true
		}
	}
	return false
}

func getInspectCmdOutput(node config.NodeInfo, cmd check.Command) ([]byte, error) {
	path, err := expandPath(node.SSHKeyPath)
	if err != nil {
		return nil, err
	}

	pubKey, err := parsePublicKey(path)
	if err != nil {
		return nil, err
	}

	khPath, err := expandPath(knownHostsFile)
	if err != nil {
		return nil, err
	}

	hostKeyCallback, err := kh.New(khPath)
	if err != nil {
		return nil, err
	}

	config := &ssh.ClientConfig{
		User:            node.User,
		Auth:            []ssh.AuthMethod{pubKey},
		HostKeyCallback: hostKeyCallback,
	}

	conn, err := ssh.Dial("tcp", node.Address+":"+node.Port, config)
	if err != nil {
		return nil, err
	}
	defer conn.Close()

	out, err := runCommand(fmt.Sprintf("docker inspect %s --format {{.Args}}", cmd), conn)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func expandPath(path string) (string, error) {
	if len(path) == 0 || path[0] != '~' {
		return path, nil
	}

	usr, err := user.Current()
	if err != nil {
		return "", err
	}
	return filepath.Join(usr.HomeDir, path[1:]), nil
}

func parsePublicKey(path string) (ssh.AuthMethod, error) {
	key, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	signer, err := ssh.ParsePrivateKey(key)
	if err != nil {
		return nil, err
	}
	return ssh.PublicKeys(signer), nil
}

func runCommand(cmd string, conn *ssh.Client) ([]byte, error) {
	sess, err := conn.NewSession()
	if err != nil {
		return nil, err
	}
	defer sess.Close()
	out, err := sess.Output(cmd)
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
