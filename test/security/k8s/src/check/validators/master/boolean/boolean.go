package boolean

import (
	"strings"
)

// IsSingleFlagPresent checks presence of selected flag and whether it was used once.
func IsSingleFlagPresent(flag string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}
	return true
}

// IsFlagAbsent checks absence of selected flag in parameters.
func IsFlagAbsent(flag string, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 0 {
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
