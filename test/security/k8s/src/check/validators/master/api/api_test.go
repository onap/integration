package api_test

import (
	. "check/validators/master/api"

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
			"--authorization-mode=Node,RBAC",
			"--audit-log-path=/var/log/apiserver/audit.log",
			"--audit-log-maxage=30",
			"--audit-log-maxbackup=10",
			"--audit-log-maxsize=100",
			"--kubelet-certificate-authority=TrustedCA",
			"--client-ca-file=/etc/kubernetes/ssl/ca.pem",
			"--etcd-cafile=/etc/kubernetes/etcd/ca.pem",
			"--service-account-key-file=/etc/kubernetes/ssl/kube-service-account-token-key.pem",
			"--kubelet-client-certificate=/etc/kubernetes/ssl/cert.pem",
			"--kubelet-client-key=/etc/kubernetes/ssl/key.pem",
			"--etcd-certfile=/etc/kubernetes/etcd/cert.pem",
			"--etcd-keyfile=/etc/kubernetes/etcd/key.pem",
			"--tls-cert-file=/etc/kubernetes/ssl/cert.pem",
			"--tls-private-key-file=/etc/kubernetes/ssl/key.pem",
			"--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256," +
				"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305," +
				"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305," +
				"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384," +
				"TLS_RSA_WITH_AES_128_GCM_SHA256",
		}

		// kubeApiServerDublin was obtained from virtual environment for testing
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
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Anonymous requests",
			func(params []string, expected bool) {
				Expect(IsAnonymousAuthDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Profiling",
			func(params []string, expected bool) {
				Expect(IsProfilingDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--profiling=true"}, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("HTTPS for kubelet",
			func(params []string, expected bool) {
				Expect(IsKubeletHTTPSAbsentOrEnabled(params)).To(Equal(expected))
			},
			Entry("Is explicitly disabled on insecure cluster", []string{"--kubelet-https=false"}, false),
			Entry("Should be absent or set to true on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent or set to true on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Repairing malformed updates",
			func(params []string, expected bool) {
				Expect(IsRepairMalformedUpdatesDisabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly enabled on insecure cluster", []string{"--repair-malformed-updates=true"}, false),
			Entry("Should be set to false on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set to false on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Service account lookup",
			func(params []string, expected bool) {
				Expect(IsServiceAccountLookupEnabled(params)).To(Equal(expected))
			},
			Entry("Is not set on insecure cluster", []string{}, false),
			Entry("Is explicitly disabled on insecure cluster", []string{"--service-account-lookup=false"}, false),
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
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Token authentication file",
			func(params []string, expected bool) {
				Expect(IsTokenAuthFileAbsent(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--token-auth-file=/path/to/file"}, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Audit log path",
			func(params []string, expected bool) {
				Expect(IsAuditLogPathSet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--audit-log-path="}, false),
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("Kubelet certificate authority",
			func(params []string, expected bool) {
				Expect(IsKubeletCertificateAuthoritySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--kubelet-certificate-authority="}, false),
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
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Etcd certificate authority",
			func(params []string, expected bool) {
				Expect(IsEtcdCertificateAuthoritySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"-etcd-cafile="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Service account key",
			func(params []string, expected bool) {
				Expect(IsServiceAccountKeySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--service-account-key-file="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Kubelet client certificate and key",
			func(params []string, expected bool) {
				Expect(IsKubeletClientCertificateAndKeySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--kubelet-client-certificate= --kubelet-client-key="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Etcd certificate and key",
			func(params []string, expected bool) {
				Expect(IsEtcdCertificateAndKeySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--etcd-certfile= --etcd-keyfile="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("TLS certificate and key",
			func(params []string, expected bool) {
				Expect(IsTLSCertificateAndKeySet(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--tls-cert-file= --tls-private-key-file="}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)
	})

	Describe("Address and port flags", func() {
		DescribeTable("Bind address",
			func(params []string, expected bool) {
				Expect(IsInsecureBindAddressAbsentOrLoopback(params)).To(Equal(expected))
			},
			Entry("Is not absent on insecure cluster", []string{"--insecure-bind-address=1.2.3.4"}, false),
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
			Entry("Should be set to 0 on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Secure bind port",
			func(params []string, expected bool) {
				Expect(IsSecurePortAbsentOrValid(params)).To(Equal(expected))
			},
			Entry("Is explicitly disabled on insecure cluster", []string{"--secure-port=0"}, false),
			Entry("Should be absent or set to valid port on CIS-compliant cluster", kubeApiServerCISCompliant, true),
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
			Entry("Is absent on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be set appropriately on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("Request timeout",
			func(params []string, expected bool) {
				Expect(IsRequestTimeoutValid(params)).To(Equal(expected))
			},
			Entry("Is empty on insecure cluster", []string{"--request-timeout="}, false),
			Entry("Is too high on insecure cluster", []string{"--request-timeout=600"}, false),
			Entry("Should be set only if needed on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be set only if needed on Dublin cluster", kubeApiServerDublin, true),
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
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("AlwaysPullImages admission control plugin",
			func(params []string, expected bool) {
				Expect(IsAlwaysPullImagesAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("DenyEscalatingExec admission control plugin",
			func(params []string, expected bool) {
				Expect(IsDenyEscalatingExecAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("SecurityContextDeny admission control plugin",
			func(params []string, expected bool) {
				Expect(IsSecurityContextDenyAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("PodSecurityPolicy admission control plugin",
			func(params []string, expected bool) {
				Expect(IsPodSecurityPolicyAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
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
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("NodeRestriction admission control plugin",
			func(params []string, expected bool) {
				Expect(IsNodeRestrictionAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be present on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("EventRateLimit admission control plugin",
			func(params []string, expected bool) {
				Expect(IsEventRateLimitAdmissionControlPluginIncluded(params)).To(Equal(expected))
			},
			Entry("Is not present on insecure cluster", []string{"--enable-admission-plugins=Foo,Bar"}, false),
			Entry("Is not present on insecure deprecated cluster", []string{"--admission-control=Foo,Bar"}, false),
			Entry("Is not present on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)

		DescribeTable("NamespaceLifecycle admission control plugin",
			func(params []string, expected bool) {
				Expect(IsNamespaceLifecycleAdmissionControlPluginNotExcluded(params)).To(Equal(expected))
			},
			Entry("Is explicitly disabled on insecure cluster", []string{"--disable-admission-plugins=Foo,Bar,NamespaceLifecycle,Baz,Quuz"}, false),
			Entry("Should not be disabled on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should not be disabled on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("AlwaysAllow authorization mode",
			func(params []string, expected bool) {
				Expect(IsAlwaysAllowAuthorizationModeExcluded(params)).To(Equal(expected))
			},
			Entry("Is not explicitly disabled on insecure cluster", []string{}, false),
			Entry("Is not absent on insecure cluster", []string{"--authorization-mode=Foo,Bar,AlwaysAllow,Baz,Quuz"}, false),
			Entry("Should be absent on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should be absent on Dublin cluster", kubeApiServerDublin, true),
		)

		DescribeTable("Node authorization mode",
			func(params []string, expected bool) {
				Expect(IsNodeAuthorizationModeIncluded(params)).To(Equal(expected))
			},
			Entry("Is not explicitly enabled on insecure cluster", []string{}, false),
			Entry("Is not present on insecure cluster", []string{"--authorization-mode=Foo,Bar"}, false),
			Entry("Should present on CIS-compliant cluster", kubeApiServerCISCompliant, true),
			Entry("Should present on Dublin cluster", kubeApiServerDublin, true),
		)
	})

	Describe("Flags requiring strict equality", func() {
		DescribeTable("Strong Cryptographic Ciphers",
			func(params []string, expected bool) {
				Expect(IsStrongCryptoCipherInUse(params)).To(Equal(expected))
			},
			Entry("Is absent on insecure cluster", []string{}, false),
			Entry("Is empty on insecure cluster", []string{"--tls-cipher-suites="}, false),
			Entry("Is incomplete on insecure cluster", []string{"--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"}, false),
			Entry("Is incomplete on Dublin cluster", kubeApiServerDublin, false),
			Entry("Should be complete on CIS-compliant cluster", kubeApiServerCISCompliant, true),
		)
	})
})
