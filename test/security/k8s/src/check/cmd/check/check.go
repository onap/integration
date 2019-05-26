package main

import (
	"flag"
	"log"

	"check/rancher"
)

func main() {
	flag.Parse()
	k8sParams, err := rancher.GetK8sParams()
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("%s\n", k8sParams)
}
