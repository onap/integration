package ports_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	. "onap.local/sslendpoints/ports"
)

var _ = Describe("Ports", func() {
	const (
		notNodePort = 0
		nodePortO   = 30200
		nodePortN   = 30201
		nodePortA   = 30202
		nodePortP   = 30203
		serviceR    = "serviceR"
		serviceL    = "serviceL"
		serviceZ    = "serviceZ"

		externalIpControl = "1.2.3.4"
		internalIpControl = "192.168.121.100"
		internalIpWorker  = "192.168.121.200"
		hostnameControl   = "onap-control-1"
		hostnameWorker    = "onap-worker-1"
	)

	var (
		servicesEmpty                       *v1.ServiceList
		servicesSingleWithNodePort          *v1.ServiceList
		servicesSingleWithMultipleNodePorts *v1.ServiceList
		servicesManyWithoutNodePorts        *v1.ServiceList
		servicesManyWithNodePort            *v1.ServiceList
		servicesManyWithMultipleNodePorts   *v1.ServiceList
		servicesManyMixedNodePorts          *v1.ServiceList

		nodesEmpty             *v1.NodeList
		nodesSingleWithIP      *v1.NodeList
		nodesSingleWithBothIPs *v1.NodeList
		nodesManyWithHostnames *v1.NodeList
		nodesManyWithMixedIPs  *v1.NodeList
	)

	BeforeEach(func() {
		servicesEmpty = &v1.ServiceList{}
		servicesSingleWithNodePort = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceR},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortO)},
						},
					},
				},
			},
		}
		servicesSingleWithMultipleNodePorts = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceR},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortO)},
							v1.ServicePort{NodePort: int32(nodePortN)},
						},
					},
				},
			},
		}
		servicesManyWithoutNodePorts = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(notNodePort)},
						},
					},
				},
				v1.Service{
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(notNodePort)},
						},
					},
				},
			},
		}
		servicesManyWithNodePort = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceR},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortO)},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceL},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortN)},
						},
					},
				},
			},
		}
		servicesManyWithMultipleNodePorts = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceR},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortO)},
							v1.ServicePort{NodePort: int32(nodePortN)},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceL},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortA)},
							v1.ServicePort{NodePort: int32(nodePortP)},
						},
					},
				},
			},
		}
		servicesManyMixedNodePorts = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceR},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(notNodePort)},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceL},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortO)},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceZ},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: int32(nodePortN)},
							v1.ServicePort{NodePort: int32(nodePortA)},
						},
					},
				},
			},
		}

		nodesEmpty = &v1.NodeList{}
		nodesSingleWithIP = &v1.NodeList{
			Items: []v1.Node{
				v1.Node{
					Status: v1.NodeStatus{
						Addresses: []v1.NodeAddress{
							v1.NodeAddress{Type: "InternalIP", Address: internalIpControl},
							v1.NodeAddress{Type: "Hostname", Address: hostnameControl},
						},
					},
				},
			},
		}
		nodesSingleWithBothIPs = &v1.NodeList{
			Items: []v1.Node{
				v1.Node{
					Status: v1.NodeStatus{
						Addresses: []v1.NodeAddress{
							v1.NodeAddress{Type: "ExternalIP", Address: externalIpControl},
							v1.NodeAddress{Type: "InternalIP", Address: internalIpControl},
							v1.NodeAddress{Type: "Hostname", Address: hostnameControl},
						},
					},
				},
			},
		}
		nodesManyWithHostnames = &v1.NodeList{
			Items: []v1.Node{
				v1.Node{
					Status: v1.NodeStatus{
						Addresses: []v1.NodeAddress{
							v1.NodeAddress{Type: "Hostname", Address: hostnameControl},
						},
					},
				},
				v1.Node{
					Status: v1.NodeStatus{
						Addresses: []v1.NodeAddress{
							v1.NodeAddress{Type: "Hostname", Address: hostnameWorker},
						},
					},
				},
			},
		}
		nodesManyWithMixedIPs = &v1.NodeList{
			Items: []v1.Node{
				v1.Node{
					Status: v1.NodeStatus{
						Addresses: []v1.NodeAddress{
							v1.NodeAddress{Type: "ExternalIP", Address: externalIpControl},
							v1.NodeAddress{Type: "InternalIP", Address: internalIpControl},
							v1.NodeAddress{Type: "Hostname", Address: hostnameControl},
						},
					},
				},
				v1.Node{
					Status: v1.NodeStatus{
						Addresses: []v1.NodeAddress{
							v1.NodeAddress{Type: "InternalIP", Address: internalIpWorker},
							v1.NodeAddress{Type: "Hostname", Address: hostnameWorker},
						},
					},
				},
			},
		}
	})

	Describe("NodePorts extraction", func() {
		Context("With empty service list", func() {
			It("should report no NodePorts", func() {
				nodeports, ok := FilterNodePorts(servicesEmpty)
				Expect(ok).To(BeFalse())
				Expect(nodeports).To(BeEmpty())
			})
		})
		Context("With service using single NodePort", func() {
			It("should report single NodePort", func() {
				expected := map[int32]string{nodePortO: serviceR}
				nodeports, ok := FilterNodePorts(servicesSingleWithNodePort)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
		Context("With service using multiple NodePorts", func() {
			It("should report all NodePorts", func() {
				expected := map[int32]string{nodePortO: serviceR, nodePortN: serviceR}
				nodeports, ok := FilterNodePorts(servicesSingleWithMultipleNodePorts)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
		Context("With many services using no NodePorts", func() {
			It("should report no NodePorts", func() {
				nodeports, ok := FilterNodePorts(servicesManyWithoutNodePorts)
				Expect(ok).To(BeFalse())
				Expect(nodeports).To(BeEmpty())
			})
		})
		Context("With services using single NodePort", func() {
			It("should report all NodePorts", func() {
				expected := map[int32]string{nodePortO: serviceR, nodePortN: serviceL}
				nodeports, ok := FilterNodePorts(servicesManyWithNodePort)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
		Context("With services using multiple NodePorts", func() {
			It("should report all NodePorts", func() {
				expected := map[int32]string{
					nodePortO: serviceR, nodePortN: serviceR,
					nodePortA: serviceL, nodePortP: serviceL,
				}
				nodeports, ok := FilterNodePorts(servicesManyWithMultipleNodePorts)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
		Context("With mixed services", func() {
			It("should report all NodePorts", func() {
				expected := map[int32]string{
					nodePortO: serviceL, nodePortN: serviceZ, nodePortA: serviceZ,
				}
				nodeports, ok := FilterNodePorts(servicesManyMixedNodePorts)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
	})

	Describe("IP addresses extraction", func() {
		Context("With empty node list", func() {
			It("should report no IP addresses", func() {
				addresses, ok := FilterIPAddresses(nodesEmpty)
				Expect(ok).To(BeFalse())
				Expect(addresses).To(BeEmpty())
			})
		})
		Context("With nodes using only hostnames", func() {
			It("should report no IP addresses", func() {
				addresses, ok := FilterIPAddresses(nodesManyWithHostnames)
				Expect(ok).To(BeFalse())
				Expect(addresses).To(BeEmpty())
			})
		})
		Context("With node using only internal IP", func() {
			It("should report internal IP", func() {
				expected := []string{internalIpControl}
				addresses, ok := FilterIPAddresses(nodesSingleWithIP)
				Expect(ok).To(BeTrue())
				Expect(addresses).To(Equal(expected))
			})
		})
		Context("With node in the cloud", func() {
			It("should report all IPs in correct order", func() {
				expected := []string{externalIpControl, internalIpControl}
				addresses, ok := FilterIPAddresses(nodesSingleWithBothIPs)
				Expect(ok).To(BeTrue())
				Expect(addresses).To(Equal(expected))
			})
		})
		Context("With nodes in the mixed cloud", func() {
			It("should report external IP as the first one", func() {
				addresses, ok := FilterIPAddresses(nodesManyWithMixedIPs)
				Expect(ok).To(BeTrue())
				Expect(addresses[0]).To(Equal(externalIpControl))
			})
		})
	})
})
