package ports

import (
	"log"
	"strconv"

	v1 "k8s.io/api/core/v1"
)

// ConvertNodePorts converts CSV data to NodePorts map.
func ConvertNodePorts(data [][]string) (map[uint16]string, bool) {
	result := make(map[uint16]string)
	for _, record := range data {
		port, err := strconv.Atoi(record[1])
		if err != nil {
			log.Printf("Unable to parse port field: %v", err)
			continue
		}
		result[uint16(port)] = record[0]
	}
	return result, len(result) > 0
}

// FilterXFailNodePorts removes NodePorts expected to fail from map.
func FilterXFailNodePorts(xfails, nodeports map[uint16]string) {
	for port, xfailService := range xfails {
		service, ok := nodeports[port]
		if !ok {
			continue
		}
		if service != xfailService {
			continue
		}
		delete(nodeports, port)
	}
}

// FilterNodePorts extracts NodePorts from ServiceList.
func FilterNodePorts(services *v1.ServiceList) (map[uint16]string, bool) {
	nodeports := make(map[uint16]string)
	for _, service := range services.Items {
		for _, port := range service.Spec.Ports {
			if port.NodePort != 0 {
				nodeports[uint16(port.NodePort)] = service.ObjectMeta.Name
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
