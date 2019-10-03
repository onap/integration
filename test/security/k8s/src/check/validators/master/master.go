package master

import (
	"log"

	"check/validators/master/api"
	"check/validators/master/controllermanager"
	"check/validators/master/scheduler"
)

// CheckAPI validates API server complies with CIS guideliness.
func CheckAPI(params []string) {
	log.Println("==> API:")
	log.Printf("IsBasicAuthFileAbsent: %t\n", api.IsBasicAuthFileAbsent(params))
	log.Printf("IsTokenAuthFileAbsent: %t\n", api.IsTokenAuthFileAbsent(params))
	log.Printf("IsInsecureAllowAnyTokenAbsent: %t\n", api.IsInsecureAllowAnyTokenAbsent(params))

	log.Printf("IsAnonymousAuthDisabled: %t\n", api.IsAnonymousAuthDisabled(params))
	log.Printf("IsInsecurePortUnbound: %t\n", api.IsInsecurePortUnbound(params))
	log.Printf("IsProfilingDisabled: %t\n", api.IsProfilingDisabled(params))
	log.Printf("IsRepairMalformedUpdatesDisabled: %t\n", api.IsRepairMalformedUpdatesDisabled(params))
	log.Printf("IsServiceAccountLookupEnabled: %t\n", api.IsServiceAccountLookupEnabled(params))

	log.Printf("IsKubeletHTTPSAbsentOrEnabled: %t\n", api.IsKubeletHTTPSAbsentOrEnabled(params))
	log.Printf("IsInsecureBindAddressAbsentOrLoopback: %t\n", api.IsInsecureBindAddressAbsentOrLoopback(params))
	log.Printf("IsSecurePortAbsentOrValid: %t\n", api.IsSecurePortAbsentOrValid(params))

	log.Printf("IsAlwaysAdmitAdmissionControlPluginExcluded: %t\n", api.IsAlwaysAdmitAdmissionControlPluginExcluded(params))

	log.Printf("IsAlwaysPullImagesAdmissionControlPluginIncluded: %t\n", api.IsAlwaysPullImagesAdmissionControlPluginIncluded(params))
	log.Printf("IsDenyEscalatingExecAdmissionControlPluginIncluded: %t\n", api.IsDenyEscalatingExecAdmissionControlPluginIncluded(params))
	log.Printf("IsSecurityContextDenyAdmissionControlPluginIncluded: %t\n", api.IsSecurityContextDenyAdmissionControlPluginIncluded(params))
	log.Printf("IsPodSecurityPolicyAdmissionControlPluginIncluded: %t\n", api.IsPodSecurityPolicyAdmissionControlPluginIncluded(params))
	log.Printf("IsServiceAccountAdmissionControlPluginIncluded: %t\n", api.IsServiceAccountAdmissionControlPluginIncluded(params))
	log.Printf("IsNodeRestrictionAdmissionControlPluginIncluded: %t\n", api.IsNodeRestrictionAdmissionControlPluginIncluded(params))
	log.Printf("IsEventRateLimitAdmissionControlPluginIncluded: %t\n", api.IsEventRateLimitAdmissionControlPluginIncluded(params))

	log.Printf("IsNamespaceLifecycleAdmissionControlPluginNotExcluded: %t\n", api.IsNamespaceLifecycleAdmissionControlPluginNotExcluded(params))

	log.Printf("IsAlwaysAllowAuthorizationModeExcluded: %t\n", api.IsAlwaysAllowAuthorizationModeExcluded(params))
	log.Printf("IsNodeAuthorizationModeIncluded: %t\n", api.IsNodeAuthorizationModeIncluded(params))

	log.Printf("IsAuditLogPathSet: %t\n", api.IsAuditLogPathSet(params))
	log.Printf("IsAuditLogMaxAgeValid: %t\n", api.IsAuditLogMaxAgeValid(params))
	log.Printf("IsAuditLogMaxBackupValid: %t\n", api.IsAuditLogMaxBackupValid(params))
	log.Printf("IsAuditLogMaxSizeValid: %t\n", api.IsAuditLogMaxSizeValid(params))

	log.Printf("IsRequestTimeoutValid: %t\n", api.IsRequestTimeoutValid(params))

	log.Printf("IsKubeletCertificateAuthoritySet: %t\n", api.IsKubeletCertificateAuthoritySet(params))
	log.Printf("IsClientCertificateAuthoritySet: %t\n", api.IsClientCertificateAuthoritySet(params))
	log.Printf("IsEtcdCertificateAuthoritySet: %t\n", api.IsEtcdCertificateAuthoritySet(params))

	log.Printf("IsServiceAccountKeySet: %t\n", api.IsServiceAccountKeySet(params))
	log.Printf("IsKubeletClientCertificateAndKeySet: %t\n", api.IsKubeletClientCertificateAndKeySet(params))
	log.Printf("IsEtcdCertificateAndKeySet: %t\n", api.IsEtcdCertificateAndKeySet(params))
	log.Printf("IsTLSCertificateAndKeySet: %t\n", api.IsTLSCertificateAndKeySet(params))

	log.Printf("IsStrongCryptoCipherInUse: %t\n", api.IsStrongCryptoCipherInUse(params))
}

// CheckScheduler validates scheduler complies with CIS guideliness.
func CheckScheduler(params []string) {
	log.Println("==> Scheduler:")
	log.Printf("IsProfilingDisabled: %t\n", scheduler.IsProfilingDisabled(params))
	log.Printf("IsInsecureBindAddressAbsentOrLoopback: %t\n", scheduler.IsInsecureBindAddressAbsentOrLoopback(params))
}

// CheckControllerManager validates controller manager complies with CIS guideliness.
func CheckControllerManager(params []string) {
	log.Println("==> Controller Manager:")
	log.Printf("IsProfilingDisabled: %t\n", controllermanager.IsProfilingDisabled(params))
	log.Printf("IsTerminatedPodGcThresholdValid: %t\n", controllermanager.IsTerminatedPodGcThresholdValid(params))
	log.Printf("IsUseServiceAccountCredentialsEnabled: %t\n", controllermanager.IsUseServiceAccountCredentialsEnabled(params))
	log.Printf("IsRotateKubeletServerCertificateIncluded: %t\n", controllermanager.IsRotateKubeletServerCertificateIncluded(params))
	log.Printf("IsServiceAccountPrivateKeyFileSet: %t\n", controllermanager.IsServiceAccountPrivateKeyFileSet(params))
	log.Printf("IsRootCertificateAuthoritySet: %t\n", controllermanager.IsRootCertificateAuthoritySet(params))
	log.Printf("IsInsecureBindAddressAbsentOrLoopback: %t\n", controllermanager.IsInsecureBindAddressAbsentOrLoopback(params))
}
