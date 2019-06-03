package main

import (
	"flag"
	"log"

	"check/rancher"
	"check/validators/master"
)

func main() {
	flag.Parse()
	k8sParams, err := rancher.GetK8sParams()
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("IsBasicAuthFileAbsent: %t\n", master.IsBasicAuthFileAbsent(k8sParams))
	log.Printf("IsInsecureAllowAnyTokenAbsent: %t\n", master.IsInsecureAllowAnyTokenAbsent(k8sParams))

	log.Printf("IsAnonymousAuthDisabled: %t\n", master.IsAnonymousAuthDisabled(k8sParams))
	log.Printf("IsKubeletHTTPSConnected: %t\n", master.IsKubeletHTTPSConnected(k8sParams))
	log.Printf("IsInsecurePortUnbound: %t\n", master.IsInsecurePortUnbound(k8sParams))
	log.Printf("IsProfilingDisabled: %t\n", master.IsProfilingDisabled(k8sParams))
	log.Printf("IsRepairMalformedUpdatesDisabled: %t\n", master.IsRepairMalformedUpdatesDisabled(k8sParams))

	log.Printf("IsInsecureBindAddressAbsentOrLoopback: %t\n", master.IsInsecureBindAddressAbsentOrLoopback(k8sParams))
	log.Printf("IsSecurePortAbsentOrValid: %t\n", master.IsSecurePortAbsentOrValid(k8sParams))
}
