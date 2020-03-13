package main

import (
	"flag"
	"log"
	"os"
	"path/filepath"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"

	"github.com/Ullaakut/nmap"

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

	// TODO: point out main structures
	// var (
	// 	addresses []string
	// 	nodeports map[int32]string
	// )

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

	// TODO: whitelist here before running the scan

	// extract ports for running the scan
	var ports []string
	for _, port := range nodeports {
		ports = append(ports, port)
	}

	// run nmap on the first address found for given cluster [1] filtering out SSL-tunelled ports
	// [1] https://kubernetes.io/docs/concepts/services-networking/service/#nodeport
	// "Each node proxies that port (the same port number on every Node) into your Service."
	scanner, err := nmap.NewScanner(
		nmap.WithTargets(addresses[0]),
		nmap.WithPorts(ports...),
		nmap.WithServiceInfo(),
		nmap.WithTimingTemplate(nmap.TimingAggressive),
		nmap.WithFilterPort(func(p nmap.Port) bool {
			return p.Service.Tunnel == "ssl"
		}),
	)
	if err != nil {
		log.Panicf("Unable to create nmap scanner: %v", err)
	}

	result, _, err := scanner.Run()
	if err != nil {
		log.Panicf("Scan failed: %v", err)
	}

	for _, host := range result.Hosts {
		log.Printf("Host %s\n", host.Addresses[0])

		for _, port := range host.Ports {
			log.Printf("\tPort %d open with service without SSL tunnel\n", port.ID)
		}
	}

	// TODO: join scan results with service names
	// remember that host address in the results might be ipv4 or mac - get the right one

	// report non-SSL services and their number
	log.Printf("There are %d NodePorts in the cluster\n", len(nodeports))
	os.Exit(len(nodeports))
}
