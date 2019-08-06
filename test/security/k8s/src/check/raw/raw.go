// Package raw wraps SSH commands necessary for K8s inspection.
package raw

import (
	"bytes"
	"errors"
	"io/ioutil"
	"os/user"
	"path/filepath"

	"golang.org/x/crypto/ssh"
	kh "golang.org/x/crypto/ssh/knownhosts"

	"check/config"
)

const (
	controlplane = "controlplane"
	etcd         = "etcd"
	worker       = "worker"

	k8sProcess       = "kube-apiserver"
	dockerInspectCmd = "docker inspect " + k8sProcess + " --format {{.Args}}"

	knownHostsFile = "~/.ssh/known_hosts"
)

// GetK8sParams returns parameters of running Kubernetes API servers.
// It queries only cluster nodes with "controlplane" role.
func GetK8sParams() ([]string, error) {
	nodes, err := config.GetNodesInfo()
	if err != nil {
		return []string{}, err
	}

	for _, node := range nodes {
		if isControlplaneNode(node.Role) {
			cmd, err := getK8sCmd(node)
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

func getK8sCmd(node config.NodeInfo) ([]byte, error) {
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

	out, err := runCommand(dockerInspectCmd, conn)
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

// btos converts slice of bytes to slice of strings split by white space characters.
func btos(in []byte) []string {
	var out []string
	for _, b := range bytes.Fields(in) {
		out = append(out, string(b))
	}
	return out
}
