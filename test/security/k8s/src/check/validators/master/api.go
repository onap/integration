package master

import (
	"strconv"
	"strings"
)

const (
	portDisabled = 0
	portLowest   = 1
	portHighest  = 65536

	auditLogAge     = 30
	auditLogBackups = 10
	auditLogSize    = 100

	strongCryptoCiphers = "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM" +
		"_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM" +
		"_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM" +
		"_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256"
)

// IsBasicAuthFileAbsent validates there is no basic authentication file specified.
func IsBasicAuthFileAbsent(params []string) bool {
	return isFlagAbsent("--basic-auth-file=", params)
}

// IsTokenAuthFileAbsent validates there is no token based authentication file specified.
func IsTokenAuthFileAbsent(params []string) bool {
	return isFlagAbsent("--token-auth-file=", params)
}

// IsInsecureAllowAnyTokenAbsent validates insecure tokens are not accepted.
func IsInsecureAllowAnyTokenAbsent(params []string) bool {
	return isFlagAbsent("--insecure-allow-any-token", params)
}

// isFlagAbsent checks absence of selected flag in parameters.
func isFlagAbsent(flag string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 0 {
		return false
	}
	return true
}

// IsAnonymousAuthDisabled validates there is single "--anonymous-auth" flag and it is set to "false".
func IsAnonymousAuthDisabled(params []string) bool {
	return hasSingleFlagArgument("--anonymous-auth=", "false", params)
}

// IsInsecurePortUnbound validates there is single "--insecure-port" flag and it is set to "0" (disabled).
func IsInsecurePortUnbound(params []string) bool {
	return hasSingleFlagArgument("--insecure-port=", strconv.Itoa(portDisabled), params)
}

// IsProfilingDisabled validates there is single "--profiling" flag and it is set to "false".
func IsProfilingDisabled(params []string) bool {
	return hasSingleFlagArgument("--profiling=", "false", params)
}

// IsRepairMalformedUpdatesDisabled validates there is single "--repair-malformed-updates" flag and it is set to "false".
func IsRepairMalformedUpdatesDisabled(params []string) bool {
	return hasSingleFlagArgument("--repair-malformed-updates=", "false", params)
}

// IsServiceAccountLookupEnabled validates there is single "--service-account-lookup" flag and it is set to "true".
func IsServiceAccountLookupEnabled(params []string) bool {
	return hasSingleFlagArgument("--service-account-lookup=", "true", params)
}

// IsStrongCryptoCipherInUse validates there is single "--tls-cipher-suites=" flag and it is set to strong crypto ciphers.
func IsStrongCryptoCipherInUse(params []string) bool {
	return hasSingleFlagArgument("--tls-cipher-suites=", strongCryptoCiphers, params)
}

// hasSingleFlagArgument checks whether selected flag was used once and has requested argument.
func hasSingleFlagArgument(flag string, argument string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}

	_, value := splitKV(found[0], "=")
	if value != argument {
		return false
	}
	return true
}

// filterFlags returns all occurrences of selected flag.
func filterFlags(strs []string, flag string) []string {
	var filtered []string
	for _, str := range strs {
		if strings.HasPrefix(str, flag) {
			filtered = append(filtered, str)
		}
	}
	return filtered
}

// splitKV splits key and value (after first occurrence of separator).
func splitKV(s, sep string) (string, string) {
	ret := strings.SplitN(s, sep, 2)
	return ret[0], ret[1]
}

// IsKubeletHTTPSAbsentOrEnabled validates there is single "--kubelet-https" flag and it is set to "true".
func IsKubeletHTTPSAbsentOrEnabled(params []string) bool {
	return isFlagAbsent("--kubelet-https=", params) ||
		hasSingleFlagArgument("--kubelet-https=", "true", params)
}

// IsInsecureBindAddressAbsentOrLoopback validates there is no insecure bind address or it is loopback address.
func IsInsecureBindAddressAbsentOrLoopback(params []string) bool {
	return isFlagAbsent("--insecure-bind-address=", params) ||
		hasSingleFlagArgument("--insecure-bind-address=", "127.0.0.1", params)
}

// IsSecurePortAbsentOrValid validates there is no secure port set explicitly or it has legal value.
func IsSecurePortAbsentOrValid(params []string) bool {
	return isFlagAbsent("--secure-port=", params) ||
		hasFlagValidPort("--secure-port=", params)
}

// hasFlagValidPort checks whether selected flag has valid port as an argument in given command.
func hasFlagValidPort(flag string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}

	_, value := splitKV(found[0], "=")
	port, err := strconv.Atoi(value) // what about empty parameter?
	if err != nil {
		return false
	}
	if port < portLowest || port > portHighest {
		return false
	}
	return true
}

// IsAlwaysAdmitAdmissionControlPluginExcluded validates AlwaysAdmit is excluded from admission control plugins.
func IsAlwaysAdmitAdmissionControlPluginExcluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return !hasFlagArgumentIncluded("--enable-admission-plugins=", "AlwaysAdmit", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return !hasFlagArgumentIncluded("--admission-control=", "AlwaysAdmit", params)
	}
	return false
}

// IsAlwaysPullImagesAdmissionControlPluginIncluded validates AlwaysPullImages is included in admission control plugins.
func IsAlwaysPullImagesAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "AlwaysPullImages", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "AlwaysPullImages", params)
	}
	return false
}

// IsDenyEscalatingExecAdmissionControlPluginIncluded validates DenyEscalatingExec is included in admission control plugins.
func IsDenyEscalatingExecAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "DenyEscalatingExec", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "DenyEscalatingExec", params)
	}
	return false
}

// IsSecurityContextDenyAdmissionControlPluginIncluded validates SecurityContextDeny is included in admission control plugins.
func IsSecurityContextDenyAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "SecurityContextDeny", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "SecurityContextDeny", params)
	}
	return false
}

// IsPodSecurityPolicyAdmissionControlPluginIncluded validates PodSecurityPolicy is included in admission control plugins.
func IsPodSecurityPolicyAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "PodSecurityPolicy", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "PodSecurityPolicy", params)
	}
	return false
}

// IsServiceAccountAdmissionControlPluginIncluded validates ServiceAccount is included in admission control plugins.
func IsServiceAccountAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "ServiceAccount", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "ServiceAccount", params)
	}
	return false
}

// IsNodeRestrictionAdmissionControlPluginIncluded validates NodeRestriction is included in admission control plugins.
func IsNodeRestrictionAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "NodeRestriction", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "NodeRestriction", params)
	}
	return false
}

// IsEventRateLimitAdmissionControlPluginIncluded validates EventRateLimit is included in admission control plugins.
func IsEventRateLimitAdmissionControlPluginIncluded(params []string) bool {
	if isSingleFlagPresent("--enable-admission-plugins=", params) {
		return hasFlagArgumentIncluded("--enable-admission-plugins=", "EventRateLimit", params)
	}
	if isSingleFlagPresent("--admission-control=", params) {
		return hasFlagArgumentIncluded("--admission-control=", "EventRateLimit", params)
	}
	return false
}

// IsNamespaceLifecycleAdmissionControlPluginNotExcluded validates NamespaceLifecycle is excluded from admission control plugins.
func IsNamespaceLifecycleAdmissionControlPluginNotExcluded(params []string) bool {
	if isSingleFlagPresent("--disable-admission-plugins=", params) {
		return !hasFlagArgumentIncluded("--disable-admission-plugins=", "NamespaceLifecycle", params)
	}
	return true
}

// isSingleFlagPresent checks presence of selected flag and whether it was used once.
func isSingleFlagPresent(flag string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}
	return true
}

// hasFlagArgumentIncluded checks whether selected flag includes requested argument.
func hasFlagArgumentIncluded(flag string, argument string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}

	_, values := splitKV(found[0], "=")
	for _, v := range strings.Split(values, ",") {
		if v == argument {
			return true
		}
	}
	return false
}

// IsAlwaysAllowAuthorizationModeExcluded validates AlwaysAllow is excluded from authorization modes.
func IsAlwaysAllowAuthorizationModeExcluded(params []string) bool {
	return isSingleFlagPresent("--authorization-mode=", params) &&
		!hasFlagArgumentIncluded("--authorization-mode=", "AlwaysAllow", params)
}

// IsNodeAuthorizationModeIncluded validates Node is included in authorization modes.
func IsNodeAuthorizationModeIncluded(params []string) bool {
	return hasFlagArgumentIncluded("--authorization-mode=", "Node", params)
}

// IsAuditLogPathSet validates there is single "--audit-log-path" flag and has non-empty argument.
func IsAuditLogPathSet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--audit-log-path=", params)
}

// IsKubeletCertificateAuthoritySet validates there is single "--kubelet-certificate-authority" flag and has non-empty argument.
func IsKubeletCertificateAuthoritySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--kubelet-certificate-authority", params)
}

// IsClientCertificateAuthoritySet validates there is single "--client-ca-file" flag and has non-empty argument.
func IsClientCertificateAuthoritySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--client-ca-file", params)
}

// IsEtcdCertificateAuthoritySet validates there is single "--etcd-cafile" flag and has non-empty argument.
func IsEtcdCertificateAuthoritySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--etcd-cafile", params)
}

// IsServiceAccountKeySet validates there is single "--service-account-key-file" flag and has non-empty argument.
func IsServiceAccountKeySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--service-account-key-file", params)
}

// IsKubeletClientCertificateAndKeySet validates there are single "--kubelet-client-certificate" and "--kubelet-client-key" flags and have non-empty arguments.
func IsKubeletClientCertificateAndKeySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--kubelet-client-certificate", params) &&
		hasSingleFlagNonemptyArgument("--kubelet-client-key", params)
}

// IsEtcdCertificateAndKeySet validates there are single "--etcd-certfile" and "--etcd-keyfile" flags and have non-empty arguments.
func IsEtcdCertificateAndKeySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--etcd-certfile", params) &&
		hasSingleFlagNonemptyArgument("--etcd-keyfile", params)
}

// IsTLSCertificateAndKeySet validates there are single "--tls-cert-file" and "--tls-private-key-file" flags and have non-empty arguments.
func IsTLSCertificateAndKeySet(params []string) bool {
	return hasSingleFlagNonemptyArgument("--tls-cert-file", params) &&
		hasSingleFlagNonemptyArgument("--tls-private-key-file", params)
}

// hasSingleFlagNonemptyArgument checks whether selected flag was used once and has non-empty argument.
func hasSingleFlagNonemptyArgument(flag string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}

	_, value := splitKV(found[0], "=")
	if value == "" {
		return false
	}
	return true
}

// IsAuditLogMaxAgeValid validates audit log age is set and it has recommended value.
func IsAuditLogMaxAgeValid(params []string) bool {
	return hasSingleFlagRecommendedNumericArgument("--audit-log-maxage", auditLogAge, params)
}

// IsAuditLogMaxBackupValid validates audit log age is set and it has recommended value.
func IsAuditLogMaxBackupValid(params []string) bool {
	return hasSingleFlagRecommendedNumericArgument("--audit-log-maxbackup", auditLogBackups, params)
}

// IsAuditLogMaxSizeValid validates audit log age is set and it has recommended value.
func IsAuditLogMaxSizeValid(params []string) bool {
	return hasSingleFlagRecommendedNumericArgument("--audit-log-maxsize", auditLogSize, params)
}

// hasSingleFlagRecommendedNumericArgument checks whether selected flag was used once and has
// an argument that is greater or equal than the recommended value for given command.
func hasSingleFlagRecommendedNumericArgument(flag string, recommendation int, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}

	_, value := splitKV(found[0], "=")
	arg, err := strconv.Atoi(value) // what about empty parameter?
	if err != nil {
		return false
	}
	if arg < recommendation {
		return false
	}
	return true
}
