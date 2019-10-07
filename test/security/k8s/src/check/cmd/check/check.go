package main

import (
	"flag"
	"log"

	"check"
	"check/rancher"
	"check/raw"
	"check/validators/master"
)

var (
	ranchercli = flag.Bool("ranchercli", false, "use rancher utility for accessing cluster nodes")
	rke        = flag.Bool("rke", false, "use RKE cluster definition and ssh for accessing cluster nodes (default)")
)

func main() {
	flag.Parse()
	if *ranchercli && *rke {
		log.Fatal("Not supported.")
	}

	// Use default cluster access method if none was declared explicitly.
	if !(*ranchercli || *rke) {
		*rke = true
	}

	var info check.Informer

	switch {
	case *ranchercli:
		info = &rancher.Rancher{}
	case *rke:
		info = &raw.Raw{}
	default:
		log.Fatal("Missing cluster access method.")
	}

	apiParams, err := info.GetAPIParams()
	if err != nil {
		log.Fatal(err)
	}
	master.CheckAPI(apiParams)

	schedulerParams, err := info.GetSchedulerParams()
	if err != nil {
		log.Fatal(err)
	}
	master.CheckScheduler(schedulerParams)

	controllerManagerParams, err := info.GetControllerManagerParams()
	if err != nil {
		log.Fatal(err)
	}
	master.CheckControllerManager(controllerManagerParams)

	_, err = info.GetEtcdParams()
	if err != nil {
		switch err {
		case check.ErrNotImplemented:
			log.Print(err) // Fail softly.
		default:
			log.Fatal(err)
		}
	}
}
