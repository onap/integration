package main

import (
	"flag"
	"log"

	"check"
	"check/raw"
	"check/validators/master"
)

var (
	rke = flag.Bool("rke", true, "use RKE cluster definition and ssh for accessing cluster nodes (default)")
)

func main() {
	flag.Parse()
	if !(*rke) {
		log.Fatal("Not supported.")
	}

	var info check.Informer

	switch {
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
