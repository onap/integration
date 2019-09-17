package master

import (
	"strconv"
	"strings"
)

const (
	portDisabled = 0
	portLowest   = 1
	portHighest  = 65536
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
