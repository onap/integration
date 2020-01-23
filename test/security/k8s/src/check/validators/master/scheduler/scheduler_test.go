package scheduler_test

import (
	. "github.com/onsi/ginkgo/extensions/table"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "check/validators/master/scheduler"
)

var _ = Describe("Scheduler", func() {
	var (
		// kubeSchedulerCISCompliant uses secure defaults or follows CIS guidelines explicitly.
		kubeSchedulerCISCompliant = []string{
			"--profiling=false",
		}

		// kubeSchedulerDublin was obtained from virtual environment for testing
		// (introduced in Change-Id: I54ada5fade3b984dedd1715f20579e3ce901faa3).
		kubeSchedulerDublin = []string{
			"--kubeconfig=/etc/kubernetes/ssl/kubecfg-kube-scheduler.yaml",
			"--address=0.0.0.0",
			"--profiling=false",
			"--leader-elect=true",
			"--v=2",
		}
	)

	Describe("Boolean flag", func() {
		DescribeTable("Profiling",
			func(params []string, expected bool) {
				Expect(IsProfilingDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--profiling=true"}, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeSchedulerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeSchedulerDublin, true),
		)
	})

	Describe("Address flag", func() {
		DescribeTable("Bind address",
			func(params []string, expected bool) {
				Expect(IsInsecureBindAddressAbsentOrLoopback(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--address=1.2.3.4"}, false),
			Entry("Is not absent nor set to loopback on Dublin cluster", kubeSchedulerDublin, false),
			Entry("Should be absent or set to loopback on CIS-compliant cluster", kubeSchedulerCISCompliant, true),
		)
	})
})
