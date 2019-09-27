package scheduler

import (
	"check/validators/master/args"
	"check/validators/master/boolean"
)

// IsProfilingDisabled validates there is single "--profiling" flag and it is set to "false".
func IsProfilingDisabled(params []string) bool {
	return args.HasSingleFlagArgument("--profiling=", "false", params)
}

// IsInsecureBindAddressAbsentOrLoopback validates there is no insecure bind address or it is loopback address.
func IsInsecureBindAddressAbsentOrLoopback(params []string) bool {
	return boolean.IsFlagAbsent("--address=", params) ||
		args.HasSingleFlagArgument("--address=", "127.0.0.1", params)
}
