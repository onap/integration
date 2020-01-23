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
		kubeControllerManagerCISCompliant = []string{
			"--profiling=false",
			"--use-service-account-credentials=true",
			"--feature-gates=RotateKubeletServerCertificate=true",
			"--terminated-pod-gc-threshold=10",
			"--service-account-private-key-file=/etc/kubernetes/ssl/kube-service-account-token-key.pem",
			"--root-ca-file=/etc/kubernetes/ssl/kube-ca.pem",
		}

		// kubeControllerManagerDublin was obtained from virtual environment for testing
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

	Describe("Boolean flags", func() {
		DescribeTable("Profiling",
			func(params []string, expected bool) {
				Expect(IsProfilingDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--profiling=true"}, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeControllerManagerDublin, true),
		)

		DescribeTable("Service account credentials use",
			func(params []string, expected bool) {
				Expect(IsUseServiceAccountCredentialsEnabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly disabled on insecure cluster", []string{"--use-service-account-credentials=false"}, false),
			Entry("Should be set to true on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
			Entry("Should be set to true on Dublin cluster", kubeControllerManagerDublin, true),
		)
	})

	Describe("File path flags", func() {
		DescribeTable("Service account private key",
			func(params []string, expected bool) {
				Expect(IsServiceAccountPrivateKeyFileSet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{""}, false),
			Entry("Is empty on insecure cluster", []string{"--service-account-private-key-file="}, false),
			Entry("Should be explicitly set on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
			Entry("Should be explicitly set on Dublin cluster", kubeControllerManagerDublin, true),
		)

		DescribeTable("Root certificate authority",
			func(params []string, expected bool) {
				Expect(IsRootCertificateAuthoritySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{""}, false),
			Entry("Is empty on insecure cluster", []string{"--root-ca-file="}, false),
			Entry("Should be explicitly set on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
			Entry("Should be explicitly set on Dublin cluster", kubeControllerManagerDublin, true),
		)
	})

	Describe("Address flag", func() {
		DescribeTable("Bind address",
			func(params []string, expected bool) {
				Expect(IsInsecureBindAddressAbsentOrLoopback(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--address=1.2.3.4"}, false),
			Entry("Is not absent nor set to loopback on Dublin cluster", kubeControllerManagerDublin, false),
			Entry("Should be absent or set to loopback on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
		)
	})

	Describe("Numeric flags", func() {
		DescribeTable("Terminated pod garbage collector threshold",
			func(params []string, expected bool) {
				Expect(IsTerminatedPodGcThresholdValid(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{""}, false),
			Entry("Is empty on insecure cluster", []string{"--terminated-pod-gc-threshold="}, false),
			Entry("Should be explicitly set on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
			Entry("Should be explicitly set on Dublin cluster", kubeControllerManagerDublin, true),
		)
	})

	Describe("Argument list flags", func() {
		DescribeTable("RotateKubeletServerCertificate",
			func(params []string, expected bool) {
				Expect(IsRotateKubeletServerCertificateIncluded(params)).To(Equal(expected))
			},
			Entry("Is not enabled on insecure cluster", []string{"--feature-gates=Foo=Bar,Baz=Quuz"}, false),
			Entry("Is explicitly disabled on insecure cluster", []string{"--feature-gates=Foo=Bar,RotateKubeletServerCertificate=false,Baz=Quuz"}, false),
			Entry("Is not enabled on Dublin cluster", kubeControllerManagerDublin, false),
			Entry("Should be enabled on CIS-compliant cluster", kubeControllerManagerCISCompliant, true),
		)
	})
})
