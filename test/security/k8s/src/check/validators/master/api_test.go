package master_test

import (
	. "check/validators/master"

	. "github.com/onsi/ginkgo/extensions/table"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Api", func() {
	var (
		// kubeApiServerCISCompliant uses secure defaults or follows CIS guidelines explicitly.
		kubeApiServerCISCompliant = []string{
			"--anonymous-auth=false",
			"--insecure-port=0",
			"--profiling=false",
			"--repair-malformed-updates=false",
			"--service-account-lookup=true",
			"--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount," +
				"TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass," +
				"PersistentVolumeClaimResize,MutatingAdmissionWebhook,ValidatingAdmissionWebhook," +
				"ResourceQuota,AlwaysPullImages,DenyEscalatingExec,SecurityContextDeny," +
				"PodSecurityPolicy,NodeRestriction,EventRateLimit",
			"--authorization-mode=RBAC",
			"--audit-log-path=/var/log/apiserver/audit.log",
			"--audit-log-maxage=30",
			"--audit-log-maxbackup=10",
			"--audit-log-maxsize=100",
			"--kubelet-certificate-authority=TrustedCA",
			"--client-ca-file=/etc/kubernetes/ssl/ca.pem",
			"--etcd-cafile=/etc/kubernetes/etcd/ca.pem",
		}

		// kubeApiServerCasablanca was obtained from virtual environment for testing
		// (introduced in Change-Id: I57f9f3caac0e8b391e9ed480f6bebba98e006882).
		kubeApiServerCasablanca = []string{
			"--storage-backend=etcd2",
			"--storage-media-type=application/json",
			"--service-cluster-ip-range=10.43.0.0/16",
			"--etcd-servers=https://etcd.kubernetes.rancher.internal:2379",
			"--insecure-bind-address=0.0.0.0",
			"--insecure-port=0",
			"--cloud-provider=rancher",
			"--allow-privileged=true",
			"--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount," +
				"PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,ResourceQuota",
			"--client-ca-file=/etc/kubernetes/ssl/ca.pem",
			"--tls-cert-file=/etc/kubernetes/ssl/cert.pem",
			"--tls-private-key-file=/etc/kubernetes/ssl/key.pem",
			"--kubelet-client-certificate=/etc/kubernetes/ssl/cert.pem",
			"--kubelet-client-key=/etc/kubernetes/ssl/key.pem",
			"--runtime-config=batch/v2alpha1",
			"--anonymous-auth=false",
			"--authentication-token-webhook-config-file=/etc/kubernetes/authconfig",
			"--runtime-config=authentication.k8s.io/v1beta1=true",
			"--external-hostname=kubernetes.kubernetes.rancher.internal",
			"--etcd-cafile=/etc/kubernetes/etcd/ca.pem",
			"--etcd-certfile=/etc/kubernetes/etcd/cert.pem",
			"--etcd-keyfile=/etc/kubernetes/etcd/key.pem",
			"--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256," +
				"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305," +
				"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384," +
				"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
		}

		// kubeApiServerCasablanca was obtained from virtual environment for testing
		// (introduced in Change-Id: I54ada5fade3b984dedd1715f20579e3ce901faa3).
		kubeApiServerDublin = []string{
			"--requestheader-group-headers=X-Remote-Group",
			"--proxy-client-cert-file=/etc/kubernetes/ssl/kube-apiserver-proxy-client.pem",
			"--bind-address=0.0.0.0",
			"--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256," +
				"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305," +
				"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384," +
				"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
			"--cloud-provider=",
			"--etcd-cafile=/etc/kubernetes/ssl/kube-ca.pem",
			"--etcd-servers=https://172.17.0.100:2379",
			"--tls-cert-file=/etc/kubernetes/ssl/kube-apiserver.pem",
			"--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount," +
				"DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook," +
				"ValidatingAdmissionWebhook,ResourceQuota,NodeRestriction,PersistentVolumeLabel",
			"--insecure-port=0",
			"--secure-port=6443",
			"--storage-backend=etcd3",
			"--kubelet-client-key=/etc/kubernetes/ssl/kube-apiserver-key.pem",
			"--requestheader-client-ca-file=/etc/kubernetes/ssl/kube-apiserver-requestheader-ca.pem",
			"--service-account-key-file=/etc/kubernetes/ssl/kube-service-account-token-key.pem",
			"--service-node-port-range=30000-32767",
			"--tls-private-key-file=/etc/kubernetes/ssl/kube-apiserver-key.pem",
			"--requestheader-username-headers=X-Remote-User",
			"--repair-malformed-updates=false",
			"--kubelet-client-certificate=/etc/kubernetes/ssl/kube-apiserver.pem",
			"--service-cluster-ip-range=10.43.0.0/16",
			"--advertise-address=172.17.0.100",
			"--profiling=false",
			"--requestheader-extra-headers-prefix=X-Remote-Extra-",
			"--etcd-certfile=/etc/kubernetes/ssl/kube-node.pem",
			"--anonymous-auth=false",
			"--etcd-keyfile=/etc/kubernetes/ssl/kube-node-key.pem",
			"--etcd-prefix=/registry",
			"--client-ca-file=/etc/kubernetes/ssl/kube-ca.pem",
			"--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
			"--requestheader-allowed-names=kube-apiserver-proxy-client",
			"--service-account-lookup=true",
			"--proxy-client-key-file=/etc/kubernetes/ssl/kube-apiserver-proxy-client-key.pem",
			"--authorization-mode=Node,RBAC",
			"--allow-privileged=true",
		}
	)

	Describe("Boolean flags", func() {
		DescribeTable("Accepting any token",
			func(params []string, expected bool) {
				Expect(IsInsecureAllowAnyTokenAbsent(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--insecure-allow-any-token"}, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Anonymous requests",
			func(params []string, expected bool) {
				Expect(IsAnonymousAuthDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to false on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be set to false on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Profiling",
			func(params []string, expected bool) {
				Expect(IsProfilingDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--profiling=true"}, false),
			Entry("Is not set on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("HTTPS for kubelet",
			func(params []string, expected bool) {
				Expect(IsKubeletHTTPSAbsentOrEnabled(params)).To(Equal(expected))
			},
			Entry("Is explicitly disabled on insecure cluster", []string{"--kubelet-https=false"}, false),
			Entry("Should be absent or set to true on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent or set to true on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be absent or set to true on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Repairing malformed updates",
			func(params []string, expected bool) {
				Expect(IsRepairMalformedUpdatesDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--repair-malformed-updates=true"}, false),
			Entry("Is not set on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Service account lookup",
			func(params []string, expected bool) {
				Expect(IsServiceAccountLookupEnabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly disabled on insecure cluster", []string{"--service-account-lookup=false"}, false),
			Entry("Is not set on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Should be set to true on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to true on Dublin cluster", kubeApiServerDublin, true),
		)
	})

	Describe("File path flags", func() {
		DescribeTable("Basic authentication file",
			func(params []string, expected bool) {
				Expect(IsBasicAuthFileAbsent(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--basic-auth-file=/path/to/file"}, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Token authentication file",
			func(params []string, expected bool) {
				Expect(IsTokenAuthFileAbsent(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--token-auth-file=/path/to/file"}, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Audit log path",
			func(params []string, expected bool) {
				Expect(IsAuditLogPathSet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--audit-log-path="}, false),
			Entry("Is absent on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("Kubelet certificate authority",
			func(params []string, expected bool) {
				Expect(IsKubeletCertificateAuthoritySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--kubelet-certificate-authority="}, false),
			Entry("Is absent on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("Client certificate authority",
			func(params []string, expected bool) {
				Expect(IsClientCertificateAuthoritySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--client-ca-file="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Etcd certificate authority",
			func(params []string, expected bool) {
				Expect(IsEtcdCertificateAuthoritySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"-etcd-cafile="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)
	})

	Describe("Address and port flags", func() {
		DescribeTable("Bind address",
			func(params []string, expected bool) {
				Expect(IsInsecureBindAddressAbsentOrLoopback(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--insecure-bind-address=1.2.3.4"}, false),
			Entry("Is not absent nor set to loopback on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Should be absent or set to loopback on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent or set to loopback on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Bind port",
			func(params []string, expected bool) {
				Expect(IsInsecurePortUnbound(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--insecure-port=1234"}, false),
			Entry("Should be set to 0 on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to 0 on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be set to 0 on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Secure bind port",
			func(params []string, expected bool) {
				Expect(IsSecurePortAbsentOrValid(params)).To(Equal(expected))
			},
			Entry("Is explicitly disabled on insecure cluster", []string{"--secure-port=0"}, false),
			Entry("Should be absent or set to valid port on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent or set to valid port on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be absent or set to valid port on Dublin cluster", kubeApiServerDublin, true),
		)
	})

	Describe("Numeric flags", func() {
		DescribeTable("Audit log age",
			func(params []string, expected bool) {
				Expect(IsAuditLogMaxAgeValid(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--audit-log-maxage="}, false),
			Entry("Is insufficient on insecure cluster", []string{"--audit-log-maxage=5"}, false),
			Entry("Is absent on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be set appropriately on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("Audit log backups",
			func(params []string, expected bool) {
				Expect(IsAuditLogMaxBackupValid(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--audit-log-maxbackup="}, false),
			Entry("Is insufficient on insecure cluster", []string{"--audit-log-maxbackup=2"}, false),
			Entry("Is absent on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be set appropriately on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("Audit log size",
			func(params []string, expected bool) {
				Expect(IsAuditLogMaxSizeValid(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--audit-log-maxsize="}, false),
			Entry("Is insufficient on insecure cluster", []string{"--audit-log-maxsize=5"}, false),
			Entry("Is absent on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be set appropriately on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)
	})

	Describe("Argument list flags", func() {
		DescribeTable("AlwaysAdmit admission control plugin",
			func(params []string, expected bool) {
				Expect(IsAlwaysAdmitAdmissionControlPluginExcluded(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar,AlwaysAdmit,Baz,Quuz"}, false),
			Entry("Is not absent on insecure deprecated cluster", []string{"--admission-control=Foo,Bar,AlwaysAdmit,Baz,Quuz"}, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("AlwaysPullImages admission control plugin",
			func(params []string, expected bool) {
				Expect(IsAlwaysPullImagesAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("DenyEscalatingExec admission control plugin",
			func(params []string, expected bool) {
				Expect(IsDenyEscalatingExecAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("SecurityContextDeny admission control plugin",
			func(params []string, expected bool) {
				Expect(IsSecurityContextDenyAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("PodSecurityPolicy admission control plugin",
			func(params []string, expected bool) {
				Expect(IsPodSecurityPolicyAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("ServiceAccount admission control plugin",
			func(params []string, expected bool) {
				Expect(IsServiceAccountAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("NodeRestriction admission control plugin",
			func(params []string, expected bool) {
				Expect(IsNodeRestrictionAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("EventRateLimit admission control plugin",
			func(params []string, expected bool) {
				Expect(IsEventRateLimitAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("NamespaceLifecycle admission control plugin",
			func(params []string, expected bool) {
				Expect(IsNamespaceLifecycleAdmissionControlPluginNotExcluded(params)).To(Equal(expected))
			},
			Entry("Is explicitly disabled on insecure cluster", []string{"--disable-admission-plugins=Foo,Bar,NamespaceLifecycle,Baz,Quuz"}, false),
			Entry("Should not be disabled on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should not be disabled on Casablanca cluster", kubeApiServerCasablanca, true),
			Entry("Should not be disabled on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("AlwaysAllow authorization mode",
			func(params []string, expected bool) {
				Expect(IsAlwaysAllowAuthorizationModeExcluded(params)).To(Equal(expected))
			},
			Entry("Is not explicitly disabled on insecure cluster", []string{}, false),
			Entry("Is not absent on insecure cluster", []string{"--authorization-mode=Foo,Bar,AlwaysAllow,Baz,Quuz"}, false),
			Entry("Is not explicitly disabled on Casablanca cluster", kubeApiServerCasablanca, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)
	})
})
