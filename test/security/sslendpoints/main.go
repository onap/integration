package main

import (
	"flag"
	"log"
	"os"
	"path/filepath"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"

	"onap.local/sslendpoints/ports"
)

func main() {
	var kubeconfig *string
	if home := os.Getenv("HOME"); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()

	// use the current context in kubeconfig
	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		log.Panicf("Unable to build cluster config: %v", err)
	}

	// create the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Panicf("Unable to build client: %v", err)
	}

	// get list of nodes to extract addresses for running scan
	nodes, err := clientset.CoreV1().Nodes().List(metav1.ListOptions{})
	if err != nil {
		log.Panicf("Unable to get list of nodes: %v", err)
	}

	// filter out addresses for running scan
	addresses, ok := ports.FilterIPAddresses(nodes)
	if !ok {
		log.Println("There are no IP addresses to run scan")
		os.Exit(0)
	}

	// get list of services to extract nodeport information
	services, err := clientset.CoreV1().Services("").List(metav1.ListOptions{})
	if err != nil {
		log.Panicf("Unable to get list of services: %v", err)
	}

	// filter out nodeports with corresponding services from service list
	nodeports, ok := ports.FilterNodePorts(services)
	if !ok {
		log.Println("There are no NodePorts in the cluster")
		os.Exit(0)
	}
	log.Printf("There are %d NodePorts in the cluster\n", len(nodeports))
	os.Exit(len(nodeports))
}
