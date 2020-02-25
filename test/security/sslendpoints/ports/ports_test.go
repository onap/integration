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
	)

	var (
		servicesEmpty                       *v1.ServiceList
		servicesSingleWithNodePort          *v1.ServiceList
		servicesSingleWithMultipleNodePorts *v1.ServiceList
		servicesManyWithoutNodePorts        *v1.ServiceList
		servicesManyWithNodePort            *v1.ServiceList
		servicesManyWithMultipleNodePorts   *v1.ServiceList
		servicesManyMixedNodePorts          *v1.ServiceList
	)

	BeforeEach(func() {
		servicesEmpty = &v1.ServiceList{}
		servicesSingleWithNodePort = &v1.ServiceList{
			Items: []v1.Service{
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceR},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: nodePortO},
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
							v1.ServicePort{NodePort: nodePortO},
							v1.ServicePort{NodePort: nodePortN},
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
							v1.ServicePort{NodePort: notNodePort},
						},
					},
				},
				v1.Service{
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: notNodePort},
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
							v1.ServicePort{NodePort: nodePortO},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceL},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: nodePortN},
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
							v1.ServicePort{NodePort: nodePortO},
							v1.ServicePort{NodePort: nodePortN},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceL},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: nodePortA},
							v1.ServicePort{NodePort: nodePortP},
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
							v1.ServicePort{NodePort: notNodePort},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceL},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: nodePortO},
						},
					},
				},
				v1.Service{
					ObjectMeta: metav1.ObjectMeta{Name: serviceZ},
					Spec: v1.ServiceSpec{
						Ports: []v1.ServicePort{
							v1.ServicePort{NodePort: nodePortN},
							v1.ServicePort{NodePort: nodePortA},
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
				expected := map[uint16]string{nodePortO: serviceR}
				nodeports, ok := FilterNodePorts(servicesSingleWithNodePort)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
		Context("With service using multiple NodePorts", func() {
			It("should report all NodePorts", func() {
				expected := map[uint16]string{nodePortO: serviceR, nodePortN: serviceR}
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
				expected := map[uint16]string{nodePortO: serviceR, nodePortN: serviceL}
				nodeports, ok := FilterNodePorts(servicesManyWithNodePort)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
		Context("With services using multiple NodePorts", func() {
			It("should report all NodePorts", func() {
				expected := map[uint16]string{
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
				expected := map[uint16]string{
					nodePortO: serviceL, nodePortN: serviceZ, nodePortA: serviceZ,
				}
				nodeports, ok := FilterNodePorts(servicesManyMixedNodePorts)
				Expect(ok).To(BeTrue())
				Expect(nodeports).To(Equal(expected))
			})
		})
	})
})
