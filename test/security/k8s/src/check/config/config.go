// Package config reads relevant SSH access information from cluster config declaration.
package config

import (
	"io/ioutil"

	v3 "github.com/rancher/types/apis/management.cattle.io/v3"
	"gopkg.in/yaml.v2"
)

const (
	defaultConfigFile = "cluster.yml"
)

// NodeInfo contains role and SSH access information for a single cluster node.
type NodeInfo struct {
	Role       []string
	User       string
	Address    string
	Port       string
	SSHKeyPath string
}

// GetNodesInfo returns nodes' roles and SSH access information for a whole cluster.
func GetNodesInfo() ([]NodeInfo, error) {
	config, err := readConfig(defaultConfigFile)
	if err != nil {
		return []NodeInfo{}, err
	}

	cluster, err := parseConfig(config)
	if err != nil {
		return []NodeInfo{}, err
	}

	var nodes []NodeInfo
	for _, node := range cluster.Nodes {
		nodes = append(nodes, NodeInfo{
			node.Role, node.User, node.Address, node.Port, node.SSHKeyPath,
		})
	}
	return nodes, nil
}

func readConfig(configFile string) (string, error) {
	config, err := ioutil.ReadFile(configFile)
	if err != nil {
		return "", err
	}
	return string(config), nil
}

func parseConfig(config string) (*v3.RancherKubernetesEngineConfig, error) {
	var rkeConfig v3.RancherKubernetesEngineConfig
	if err := yaml.Unmarshal([]byte(config), &rkeConfig); err != nil {
		return nil, err
	}
	return &rkeConfig, nil
}
