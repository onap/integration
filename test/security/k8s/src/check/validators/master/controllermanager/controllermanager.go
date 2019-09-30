package controllermanager

import (
	"check/validators/master/args"
	"check/validators/master/boolean"
)

// IsProfilingDisabled validates there is single "--profiling" flag and it is set to "false".
func IsProfilingDisabled(params []string) bool {
	return args.HasSingleFlagArgument("--profiling=", "false", params)
}

// IsUseServiceAccountCredentialsEnabled validates there is single "--use-service-account-credentials" flag and it is set to "true".
func IsUseServiceAccountCredentialsEnabled(params []string) bool {
	return args.HasSingleFlagArgument("--use-service-account-credentials=", "true", params)
}

// IsRotateKubeletServerCertificateIncluded validates RotateKubeletServerCertificate=true is included.
func IsRotateKubeletServerCertificateIncluded(params []string) bool {
	return args.HasFlagArgumentIncluded("--feature-gates=", "RotateKubeletServerCertificate=true", params)
}

// IsInsecureBindAddressAbsentOrLoopback validates there is no insecure bind address or it is loopback address.
func IsInsecureBindAddressAbsentOrLoopback(params []string) bool {
	return boolean.IsFlagAbsent("--address=", params) ||
		args.HasSingleFlagArgument("--address=", "127.0.0.1", params)
}
