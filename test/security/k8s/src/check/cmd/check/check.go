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

	master.Check(k8sParams)
}
