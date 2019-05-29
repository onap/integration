package master

import (
	"strconv"
	"strings"
)

const (
	disabledPort = 0
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
	return isFlagAbsent("--insecure_allow_any_token", params)
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

// IsKubeletHTTPSConnected validates there is single "--kubelet-https" flag and it is set to "true".
func IsKubeletHTTPSConnected(params []string) bool {
	return hasSingleFlagArgument("--kubelet-https=", "true", params)
}

// IsInsecurePortUnbound validates there is single "--insecure-port" flag and it is set to "0" (disabled).
func IsInsecurePortUnbound(params []string) bool {
	return hasSingleFlagArgument("--insecure-port=", strconv.Itoa(disabledPort), params)
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
