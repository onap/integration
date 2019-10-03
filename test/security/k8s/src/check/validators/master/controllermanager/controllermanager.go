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

// IsTerminatedPodGcThresholdValid validates terminated pod garbage collector threshold is set and it has non-empty argument.
func IsTerminatedPodGcThresholdValid(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--terminated-pod-gc-threshold", params)
}

// IsServiceAccountPrivateKeyFileSet validates service account private key is set and it has non-empty argument.
func IsServiceAccountPrivateKeyFileSet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--service-account-private-key-file", params)
}

// IsRootCertificateAuthoritySet validates root certificate authority is set and it has non-empty argument.
func IsRootCertificateAuthoritySet(params []string) bool {
	return args.HasSingleFlagNonemptyArgument("--root-ca-file", params)
}
