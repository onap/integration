package api

import (
	"strconv"

	"check/validators/master/args"
	"check/validators/master/boolean"
)

const (
	portDisabled = 0

	auditLogAge     = 30
	auditLogBackups = 10
	auditLogSize    = 100

	strongCryptoCiphers = "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM" +
		"_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM" +
		"_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM" +
		"_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256"

	requestTimeout = 60
)

// IsBasicAuthFileAbsent validates there is no basic authentication file specified.
func IsBasicAuthFileAbsent(params []string) bool {
	return boolean.IsFlagAbsent("--basic-auth-file=", params)
}

// IsTokenAuthFileAbsent validates there is no token based authentication file specified.
func IsTokenAuthFileAbsent(params []string) bool {
	return boolean.IsFlagAbsent("--token-auth-file=", params)
}

// IsInsecureAllowAnyTokenAbsent validates insecure tokens are not accepted.
func IsInsecureAllowAnyTokenAbsent(params []string) bool {
	return boolean.IsFlagAbsent("--insecure-allow-any-token", params)
}

// IsAnonymousAuthDisabled validates there is single "--anonymous-auth" flag and it is set to "false".
func IsAnonymousAuthDisabled(params []string) bool {
	return args.HasSingleFlagArgument("--anonymous-auth=", "false", params)
}

// IsInsecurePortUnbound validates there is single "--insecure-port" flag and it is set to "0" (disabled).
func IsInsecurePortUnbound(params []string) bool {
	return args.HasSingleFlagArgument("--insecure-port=", strconv.Itoa(portDisabled), params)
}

// IsProfilingDisabled validates there is single "--profiling" flag and it is set to "false".
func IsProfilingDisabled(params []string) bool {
	return args.HasSingleFlagArgument("--profiling=", "false", params)
}

// IsRepairMalformedUpdatesDisabled validates there is single "--repair-malformed-updates" flag and it is set to "false".
func IsRepairMalformedUpdatesDisabled(params []string) bool {
	return args.HasSingleFlagArgument("--repair-malformed-updates=", "false", params)
}

// IsServiceAccountLookupEnabled validates there is single "--service-account-lookup" flag and it is set to "true".
func IsServiceAccountLookupEnabled(params []string) bool {
	return args.HasSingleFlagArgument("--service-account-lookup=", "true", params)
}

// IsStrongCryptoCipherInUse validates there is single "--tls-cipher-suites=" flag and it is set to strong crypto ciphers.
func IsStrongCryptoCipherInUse(params []string) bool {
	return args.HasSingleFlagArgument("--tls-cipher-suites=", strongCryptoCiphers, params)
}

// IsKubeletHTTPSAbsentOrEnabled validates there is single "--kubelet-https" flag and it is set to "true".
func IsKubeletHTTPSAbsentOrEnabled(params []string) bool {
	return boolean.IsFlagAbsent("--kubelet-https=", params) ||
		args.HasSingleFlagArgument("--kubelet-https=", "true", params)
}

// IsInsecureBindAddressAbsentOrLoopback validates there is no insecure bind address or it is loopback address.
func IsInsecureBindAddressAbsentOrLoopback(params []string) bool {
	return boolean.IsFlagAbsent("--insecure-bind-address=", params) ||
		args.HasSingleFlagArgument("--insecure-bind-address=", "127.0.0.1", params)
}

// IsSecurePortAbsentOrValid validates there is no secure port set explicitly or it has legal value.
func IsSecurePortAbsentOrValid(params []string) bool {
	return boolean.IsFlagAbsent("--secure-port=", params) ||
		args.HasSingleFlagValidPort("--secure-port=", params)
}

// IsAlwaysAdmitAdmissionControlPluginExcluded validates AlwaysAdmit is excluded from admission control plugins.
func IsAlwaysAdmitAdmissionControlPluginExcluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return !args.HasFlagArgumentIncluded("--enable-admission-plugins=", "AlwaysAdmit", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return !args.HasFlagArgumentIncluded("--admission-control=", "AlwaysAdmit", params)
	}
	return false
}

// IsAlwaysPullImagesAdmissionControlPluginIncluded validates AlwaysPullImages is included in admission control plugins.
func IsAlwaysPullImagesAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "AlwaysPullImages", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "AlwaysPullImages", params)
	}
	return false
}

// IsDenyEscalatingExecAdmissionControlPluginIncluded validates DenyEscalatingExec is included in admission control plugins.
func IsDenyEscalatingExecAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "DenyEscalatingExec", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "DenyEscalatingExec", params)
	}
	return false
}

// IsSecurityContextDenyAdmissionControlPluginIncluded validates SecurityContextDeny is included in admission control plugins.
func IsSecurityContextDenyAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "SecurityContextDeny", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "SecurityContextDeny", params)
	}
	return false
}

// IsPodSecurityPolicyAdmissionControlPluginIncluded validates PodSecurityPolicy is included in admission control plugins.
func IsPodSecurityPolicyAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "PodSecurityPolicy", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "PodSecurityPolicy", params)
	}
	return false
}

// IsServiceAccountAdmissionControlPluginIncluded validates ServiceAccount is included in admission control plugins.
func IsServiceAccountAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "ServiceAccount", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "ServiceAccount", params)
	}
	return false
}

// IsNodeRestrictionAdmissionControlPluginIncluded validates NodeRestriction is included in admission control plugins.
func IsNodeRestrictionAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "NodeRestriction", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "NodeRestriction", params)
	}
	return false
}

// IsEventRateLimitAdmissionControlPluginIncluded validates EventRateLimit is included in admission control plugins.
func IsEventRateLimitAdmissionControlPluginIncluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--enable-admission-plugins=", params) {
		return args.HasFlagArgumentIncluded("--enable-admission-plugins=", "EventRateLimit", params)
	}
	if boolean.IsSingleFlagPresent("--admission-control=", params) {
		return args.HasFlagArgumentIncluded("--admission-control=", "EventRateLimit", params)
	}
	return false
}

// IsNamespaceLifecycleAdmissionControlPluginNotExcluded validates NamespaceLifecycle is excluded from admission control plugins.
func IsNamespaceLifecycleAdmissionControlPluginNotExcluded(params []string) bool {
	if boolean.IsSingleFlagPresent("--disable-admission-plugins=", params) {
		return !args.HasFlagArgumentIncluded("--disable-admission-plugins=", "NamespaceLifecycle", params)
	}
	return true
}

// IsAlwaysAllowAuthorizationModeExcluded validates AlwaysAllow is excluded from authorization modes.
func IsAlwaysAllowAuthorizationModeExcluded(params []string) bool {
	return boolean.IsSingleFlagPresent("--authorization-mode=", params) &&
		!args.HasFlagArgumentIncluded("--authorization-mode=", "AlwaysAllow", params)
}

// IsNodeAuthorizationModeIncluded validates Node is included in authorization modes.
func IsNodeAuthorizationModeIncluded(params []string) bool {
	return args.HasFlagArgumentIncluded("--authorization-mode=", "Node", params)
}

// IsAuditLogPathSet validates there is single "--audit-log-path" flag and has non-empty argument.
func IsAuditLogPathSet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--audit-log-path=", params)
}

// IsKubeletCertificateAuthoritySet validates there is single "--kubelet-certificate-authority" flag and has non-empty argument.
func IsKubeletCertificateAuthoritySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--kubelet-certificate-authority", params)
}

// IsClientCertificateAuthoritySet validates there is single "--client-ca-file" flag and has non-empty argument.
func IsClientCertificateAuthoritySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--client-ca-file", params)
}

// IsEtcdCertificateAuthoritySet validates there is single "--etcd-cafile" flag and has non-empty argument.
func IsEtcdCertificateAuthoritySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--etcd-cafile", params)
}

// IsServiceAccountKeySet validates there is single "--service-account-key-file" flag and has non-empty argument.
func IsServiceAccountKeySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--service-account-key-file", params)
}

// IsKubeletClientCertificateAndKeySet validates there are single "--kubelet-client-certificate" and "--kubelet-client-key" flags and have non-empty arguments.
func IsKubeletClientCertificateAndKeySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--kubelet-client-certificate", params) &&
		args.HasSingleFlagNonemptyArgument("--kubelet-client-key", params)
}

// IsEtcdCertificateAndKeySet validates there are single "--etcd-certfile" and "--etcd-keyfile" flags and have non-empty arguments.
func IsEtcdCertificateAndKeySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--etcd-certfile", params) &&
		args.HasSingleFlagNonemptyArgument("--etcd-keyfile", params)
}

// IsTLSCertificateAndKeySet validates there are single "--tls-cert-file" and "--tls-private-key-file" flags and have non-empty arguments.
func IsTLSCertificateAndKeySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--tls-cert-file", params) &&
		args.HasSingleFlagNonemptyArgument("--tls-private-key-file", params)
}

// IsAuditLogMaxAgeValid validates audit log age is set and it has recommended value.
func IsAuditLogMaxAgeValid(params []string) bool {
	return args.HasSingleFlagRecommendedNumericArgument("--audit-log-maxage", auditLogAge, params)
}

// IsAuditLogMaxBackupValid validates audit log age is set and it has recommended value.
func IsAuditLogMaxBackupValid(params []string) bool {
	return args.HasSingleFlagRecommendedNumericArgument("--audit-log-maxbackup", auditLogBackups, params)
}

// IsAuditLogMaxSizeValid validates audit log age is set and it has recommended value.
func IsAuditLogMaxSizeValid(params []string) bool {
	return args.HasSingleFlagRecommendedNumericArgument("--audit-log-maxsize", auditLogSize, params)
}

// IsRequestTimeoutValid validates request timeout is set and it has recommended value.
func IsRequestTimeoutValid(params []string) bool {
	return boolean.IsFlagAbsent("--request-timeout", params) ||
		args.HasSingleFlagValidTimeout("--request-timeout", requestTimeout, 2*requestTimeout, params)
}
