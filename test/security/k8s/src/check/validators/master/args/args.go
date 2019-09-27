package args

import (
	"strconv"
	"strings"
)

const (
	portLowest  = 1
	portHighest = 65536
)

// HasSingleFlagArgument checks whether selected flag was used once and has requested argument.
func HasSingleFlagArgument(flag string, argument string, params []string) bool {
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

// HasFlagArgumentIncluded checks whether selected flag includes requested argument.
func HasFlagArgumentIncluded(flag string, argument string, params []string) bool {
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

// HasSingleFlagNonemptyArgument checks whether selected flag was used once and has non-empty argument.
func HasSingleFlagNonemptyArgument(flag string, params []string) bool {
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

// HasSingleFlagValidPort checks whether selected flag has valid port as an argument in given command.
func HasSingleFlagValidPort(flag string, params []string) bool {
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

// HasSingleFlagValidTimeout checks whether selected flag has valid timeout as an argument in given command.
func HasSingleFlagValidTimeout(flag string, min int, max int, params []string) bool {
	found := filterFlags(params, flag)
	if len(found) != 1 {
		return false
	}

	_, value := splitKV(found[0], "=")
	timeout, err := strconv.Atoi(value) // what about empty parameter?
	if err != nil {
		return false
	}
	if timeout < min || timeout > max {
		return false
	}
	return true
}

// HasSingleFlagRecommendedNumericArgument checks whether selected flag was used once and has
// an argument that is greater or equal than the recommended value for given command.
func HasSingleFlagRecommendedNumericArgument(flag string, recommendation int, params []string) bool {
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
