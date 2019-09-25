package main

import (
	"flag"
	"log"

	"check/rancher"
	"check/raw"
	"check/validators/master"
)

var (
	ranchercli = flag.Bool("ranchercli", false, "use rancher utility for accessing cluster nodes")
	rke        = flag.Bool("rke", true, "use RKE cluster definition and ssh for accessing cluster nodes (default)")
)

func main() {
	flag.Parse()
	if *ranchercli && *rke {
		log.Fatal("Not supported.")
	}

	var (
		k8sParams []string
		err       error
	)

	switch {
	case *ranchercli:
		k8sParams, err = rancher.GetK8sParams()
	case *rke:
		k8sParams, err = raw.GetK8sParams()
	default:
		log.Fatal("Missing cluster access method.")
	}

	if err != nil {
		log.Fatal(err)
	}

	log.Printf("IsBasicAuthFileAbsent: %t\n", master.IsBasicAuthFileAbsent(k8sParams))
	log.Printf("IsTokenAuthFileAbsent: %t\n", master.IsTokenAuthFileAbsent(k8sParams))
	log.Printf("IsInsecureAllowAnyTokenAbsent: %t\n", master.IsInsecureAllowAnyTokenAbsent(k8sParams))

	log.Printf("IsAnonymousAuthDisabled: %t\n", master.IsAnonymousAuthDisabled(k8sParams))
	log.Printf("IsInsecurePortUnbound: %t\n", master.IsInsecurePortUnbound(k8sParams))
	log.Printf("IsProfilingDisabled: %t\n", master.IsProfilingDisabled(k8sParams))
	log.Printf("IsRepairMalformedUpdatesDisabled: %t\n", master.IsRepairMalformedUpdatesDisabled(k8sParams))
	log.Printf("IsServiceAccountLookupEnabled: %t\n", master.IsServiceAccountLookupEnabled(k8sParams))

	log.Printf("IsKubeletHTTPSAbsentOrEnabled: %t\n", master.IsKubeletHTTPSAbsentOrEnabled(k8sParams))
	log.Printf("IsInsecureBindAddressAbsentOrLoopback: %t\n", master.IsInsecureBindAddressAbsentOrLoopback(k8sParams))
	log.Printf("IsSecurePortAbsentOrValid: %t\n", master.IsSecurePortAbsentOrValid(k8sParams))

	log.Printf("IsAlwaysAdmitAdmissionControlPluginExcluded: %t\n", master.IsAlwaysAdmitAdmissionControlPluginExcluded(k8sParams))

	log.Printf("IsAlwaysPullImagesAdmissionControlPluginIncluded: %t\n", master.IsAlwaysPullImagesAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsDenyEscalatingExecAdmissionControlPluginIncluded: %t\n", master.IsDenyEscalatingExecAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsSecurityContextDenyAdmissionControlPluginIncluded: %t\n", master.IsSecurityContextDenyAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsPodSecurityPolicyAdmissionControlPluginIncluded: %t\n", master.IsPodSecurityPolicyAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsServiceAccountAdmissionControlPluginIncluded: %t\n", master.IsServiceAccountAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsNodeRestrictionAdmissionControlPluginIncluded: %t\n", master.IsNodeRestrictionAdmissionControlPluginIncluded(k8sParams))
	log.Printf("IsEventRateLimitAdmissionControlPluginIncluded: %t\n", master.IsEventRateLimitAdmissionControlPluginIncluded(k8sParams))

	log.Printf("IsNamespaceLifecycleAdmissionControlPluginNotExcluded: %t\n", master.IsNamespaceLifecycleAdmissionControlPluginNotExcluded(k8sParams))

	log.Printf("IsAlwaysAllowAuthorizationModeExcluded: %t\n", master.IsAlwaysAllowAuthorizationModeExcluded(k8sParams))
	log.Printf("IsNodeAuthorizationModeIncluded: %t\n", master.IsNodeAuthorizationModeIncluded(k8sParams))

	log.Printf("IsAuditLogPathSet: %t\n", master.IsAuditLogPathSet(k8sParams))
	log.Printf("IsAuditLogMaxAgeValid: %t\n", master.IsAuditLogMaxAgeValid(k8sParams))
	log.Printf("IsAuditLogMaxBackupValid: %t\n", master.IsAuditLogMaxBackupValid(k8sParams))
	log.Printf("IsAuditLogMaxSizeValid: %t\n", master.IsAuditLogMaxSizeValid(k8sParams))

	log.Printf("IsRequestTimeoutValid: %t\n", master.IsRequestTimeoutValid(k8sParams))

	log.Printf("IsKubeletCertificateAuthoritySet: %t\n", master.IsKubeletCertificateAuthoritySet(k8sParams))
	log.Printf("IsClientCertificateAuthoritySet: %t\n", master.IsClientCertificateAuthoritySet(k8sParams))
	log.Printf("IsEtcdCertificateAuthoritySet: %t\n", master.IsEtcdCertificateAuthoritySet(k8sParams))

	log.Printf("IsServiceAccountKeySet: %t\n", master.IsServiceAccountKeySet(k8sParams))
	log.Printf("IsKubeletClientCertificateAndKeySet: %t\n", master.IsKubeletClientCertificateAndKeySet(k8sParams))
	log.Printf("IsEtcdCertificateAndKeySet: %t\n", master.IsEtcdCertificateAndKeySet(k8sParams))
	log.Printf("IsTLSCertificateAndKeySet: %t\n", master.IsTLSCertificateAndKeySet(k8sParams))

	log.Printf("IsStrongCryptoCipherInUse: %t\n", master.IsStrongCryptoCipherInUse(k8sParams))
}
