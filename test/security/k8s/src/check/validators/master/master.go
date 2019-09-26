package master

import (
	"log"

	"check/validators/master/api"
)

// Check validates master node complies with CIS guideliness.
func Check(k8sParams []string) {
	log.Printf("IsBasicAuthFileAbsent: %t\n", api.IsBasicAuthFileAbsent(k8sParams))
	log.Printf("IsTokenAuthFileAbsent: %t\n", api.IsTokenAuthFileAbsent(k8sParams))
	log.Printf("IsInsecureAllowAnyTokenAbsent: %t\n", api.IsInsecureAllowAnyTokenAbsent(k8sParams))

	log.Printf("IsAnonymousAuthDisabled: %t\n", api.IsAnonymousAuthDisabled(k8sParams))
	log.Printf("IsInsecurePortUnbound: %t\n", api.IsInsecurePortUnbound(k8sParams))
	log.Printf("IsProfilingDisabled: %t\n", api.IsProfilingDisabled(k8sParams))
	log.Printf("IsRepairMalformedUpdatesDisabled: %t\n", api.IsRepairMalformedUpdatesDisabled(k8sParams))
	log.Printf("IsServiceAccountLookupEnabled: %t\n", api.IsServiceAccountLookupEnabled(k8sParams))

	log.Printf("IsKubeletHTTPSAbsentOrEnabled: %t\n", api.IsKubeletHTTPSAbsentOrEnabled(k8sParams))
	log.Printf("IsInsecureBindAddressAbsentOrLoopback: %t\n", api.IsInsecureBindAddressAbsentOrLoopback(k8sParams))
	log.Printf("IsSecurePortAbsentOrValid: %t\n", api.IsSecurePortAbsentOrValid(k8sParams))

	log.Printf("IsAlwaysAdmitAdmissionControlPluginExcluded: %t\n", api.IsAlwaysAdmitAdmissionControlPluginExcluded(k8sParams))

	log.Printf("IsAlwaysPullImagesAdmissionControlPluginIncluded: %t\n", api.IsAlwaysPullImagesAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsDenyEscalatingExecAdmissionControlPluginIncluded: %t\n", api.IsDenyEscalatingExecAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsSecurityContextDenyAdmissionControlPluginIncluded: %t\n", api.IsSecurityContextDenyAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsPodSecurityPolicyAdmissionControlPluginIncluded: %t\n", api.IsPodSecurityPolicyAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsServiceAccountAdmissionControlPluginIncluded: %t\n", api.IsServiceAccountAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsNodeRestrictionAdmissionControlPluginIncluded: %t\n", api.IsNodeRestrictionAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsEventRateLimitAdmissionControlPluginIncluded: %t\n", api.IsEventRateLimitAdmissionControlPluginIncluded(k8sParams))

	log.Printf("IsNamespaceLifecycleAdmissionControlPluginNotExcluded: %t\n", api.IsNamespaceLifecycleAdmissionControlPluginNotExcluded(k8sParams))

	log.Printf("IsAlwaysAllowAuthorizationModeExcluded: %t\n", api.IsAlwaysAllowAuthorizationModeExcluded(k8sParams))
	log.Printf("IsNodeAuthorizationModeIncluded: %t\n", api.IsNodeAuthorizationModeIncluded(k8sParams))

	log.Printf("IsAuditLogPathSet: %t\n", api.IsAuditLogPathSet(k8sParams))
	log.Printf("IsAuditLogMaxAgeValid: %t\n", api.IsAuditLogMaxAgeValid(k8sParams))
	log.Printf("IsAuditLogMaxBackupValid: %t\n", api.IsAuditLogMaxBackupValid(k8sParams))
	log.Printf("IsAuditLogMaxSizeValid: %t\n", api.IsAuditLogMaxSizeValid(k8sParams))

	log.Printf("IsRequestTimeoutValid: %t\n", api.IsRequestTimeoutValid(k8sParams))

	log.Printf("IsKubeletCertificateAuthoritySet: %t\n", api.IsKubeletCertificateAuthoritySet(k8sParams))
	log.Printf("IsClientCertificateAuthoritySet: %t\n", api.IsClientCertificateAuthoritySet(k8sParams))
	log.Printf("IsEtcdCertificateAuthoritySet: %t\n", api.IsEtcdCertificateAuthoritySet(k8sParams))

	log.Printf("IsServiceAccountKeySet: %t\n", api.IsServiceAccountKeySet(k8sParams))
	log.Printf("IsKubeletClientCertificateAndKeySet: %t\n", api.IsKubeletClientCertificateAndKeySet(k8sParams))
	log.Printf("IsEtcdCertificateAndKeySet: %t\n", api.IsEtcdCertificateAndKeySet(k8sParams))
	log.Printf("IsTLSCertificateAndKeySet: %t\n", api.IsTLSCertificateAndKeySet(k8sParams))

	log.Printf("IsStrongCryptoCipherInUse: %t\n", api.IsStrongCryptoCipherInUse(k8sParams))
}
