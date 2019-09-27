package controllermanager_test

import (
	. "github.com/onsi/ginkgo/extensions/table"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "check/validators/master/controllermanager"
)

var _ = Describe("Controllermanager", func() {
	var (
		// kubeControllerManagerCISCompliant uses secure defaults or follows CIS guidelines explicitly.
		kubeControllerManagerCISCompliant = []string{}

		// kubeControllerManagerCasablanca was obtained from virtual environment for testing
		// (introduced in Change-Id: I57f9f3caac0e8b391e9ed480f6bebba98e006882).
		kubeControllerManagerCasablanca = []string{
			"--kubeconfig=/etc/kubernetes/ssl/kubeconfig",
			"--address=0.0.0.0",
			"--root-ca-file=/etc/kubernetes/ssl/ca.pem",
			"--service-account-private-key-file=/etc/kubernetes/ssl/key.pem",
			"--allow-untagged-cloud",
			"--cloud-provider=rancher",
			"--horizontal-pod-autoscaler-use-rest-clients=false",
		}

		// kubeControllerManagerCasablanca was obtained from virtual environment for testing
		// (introduced in Change-Id: I54ada5fade3b984dedd1715f20579e3ce901faa3).
		kubeControllerManagerDublin = []string{
			"--kubeconfig=/etc/kubernetes/ssl/kubecfg-kube-controller-manager.yaml",
			"--address=0.0.0.0",
			"--root-ca-file=/etc/kubernetes/ssl/kube-ca.pem",
			"--service-account-private-key-file=/etc/kubernetes/ssl/kube-service-account-token-key.pem",
			"--terminated-pod-gc-threshold=1000",
			"--profiling=false",
			"--use-service-account-credentials=true",
			"--node-monitor-grace-period=40s",
			"--cloud-provider=",
			"--service-cluster-ip-range=10.43.0.0/16",
			"--configure-cloud-routes=false",
			"--enable-hostpath-provisioner=false",
			"--cluster-cidr=10.42.0.0/16",
			"--allow-untagged-cloud=true",
			"--pod-eviction-timeout=5m0s",
			"--allocate-node-cidrs=true",
			"--leader-elect=true",
			"--v=2",
		}
	)

	Describe("Address flag", func() {
		DescribeTable("Bind address",
			func(params []string, expected bool) {
				Expect(IsInsecureBindAddressAbsentOrLoopback(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--address=1.2.3.4"}, false),
			Entry("Is not absent nor set to loopback on Casablanca cluster", kubeControllerManagerCasablanca, false),
			Entry("Is not absent nor set to loopback on Dublin cluster", kubeControllerManagerDublin, false),
			Entry("Should be absent or set to loopback on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
		)
	})
})
