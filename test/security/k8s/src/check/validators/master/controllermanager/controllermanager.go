package controllermanager

import (
	"check/validators/master/args"
	"check/validators/master/boolean"
)

// IsInsecureBindAddressAbsentOrLoopback validates there is no insecure bind address or it is loopback address.
func IsInsecureBindAddressAbsentOrLoopback(params []string) bool {
	return boolean.IsFlagAbsent("--address=", params) ||
		args.HasSingleFlagArgument("--address=", "127.0.0.1", params)
}
