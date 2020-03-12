package ports

import (
	v1 "k8s.io/api/core/v1"
)

// FilterNodePorts extracts NodePorts from ServiceList.
func FilterNodePorts(services *v1.ServiceList) (map[int32]string, bool) {
	nodeports := make(map[int32]string)
	for _, service := range services.Items {
		for _, port := range service.Spec.Ports {
			if port.NodePort != 0 {
				nodeports[port.NodePort] = service.ObjectMeta.Name
			}
		}
	}
	return nodeports, len(nodeports) > 0
}

// FilterIPAddresses extracts IP addresses from NodeList.
// External IP addresses take precedence over internal ones.
func FilterIPAddresses(nodes *v1.NodeList) ([]string, bool) {
	addresses := make([]string, 0)
	for _, node := range nodes.Items {
		for _, address := range node.Status.Addresses {
			switch address.Type {
			case "InternalIP":
				addresses = append(addresses, address.Address)
			case "ExternalIP":
				addresses = append([]string{address.Address}, addresses...)
			}
		}
	}
	return addresses, len(addresses) > 0
}
