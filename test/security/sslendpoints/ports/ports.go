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
