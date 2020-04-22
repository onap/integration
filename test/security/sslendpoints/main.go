package main

import (
	"encoding/csv"
	"flag"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"

	"github.com/Ullaakut/nmap"

	"onap.local/sslendpoints/ports"
)

const (
	ipv4AddrType = "ipv4"

	xfailComma   = ' '
	xfailComment = '#'
	xfailFields  = 2
)

var (
	kubeconfig *string
	xfailName  *string
)

func main() {
	if home := os.Getenv("HOME"); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	xfailName = flag.String("xfail", "", "(optional) absolute path to the expected failures file")
	flag.Parse()

	xfails := make(map[uint16]string)
	if *xfailName != "" {
		xfailFile, err := os.Open(*xfailName)
		if err != nil {
			log.Printf("Unable to open expected failures file: %v", err)
			log.Println("All non-SSL NodePorts will be reported")
		}
		defer xfailFile.Close()

		r := csv.NewReader(xfailFile)
		r.Comma = xfailComma
		r.Comment = xfailComment
		r.FieldsPerRecord = xfailFields

		xfailData, err := r.ReadAll()
		if err != nil {
			log.Printf("Unable to read expected failures file: %v", err)
			log.Println("All non-SSL NodePorts will be reported")
		}

		var ok bool
		xfails, ok = ports.ConvertNodePorts(xfailData)
		if !ok {
			log.Println("No usable data in expected failures file")
			log.Println("All non-SSL NodePorts will be reported")
		}
	}

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

	// filter out expected failures here before running the scan
	ports.FilterXFailNodePorts(xfails, nodeports)

	// extract ports for running the scan
	var ports []string
	for port := range nodeports {
		ports = append(ports, strconv.Itoa(int(port)))
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
			if p.Service.Tunnel == "ssl" {
				return false
			}
			if strings.HasPrefix(p.State.State, "closed") {
				return false
			}
			if strings.HasPrefix(p.State.State, "filtered") {
				return false
			}
			return true
		}),
	)
	if err != nil {
		log.Panicf("Unable to create nmap scanner: %v", err)
	}

	result, _, err := scanner.Run()
	if err != nil {
		log.Panicf("Scan failed: %v", err)
	}

	// scan was run on a single host
	if len(result.Hosts) < 1 {
		log.Panicln("No host information in scan results")
	}

	// host address in the results might be ipv4 or mac
	for _, address := range result.Hosts[0].Addresses {
		if address.AddrType == ipv4AddrType {
			log.Printf("Host %s\n", address)
		}
	}
	log.Printf("PORT\tSERVICE")
	for _, port := range result.Hosts[0].Ports {
		log.Printf("%d\t%s\n", port.ID, nodeports[port.ID])
	}

	// report non-SSL services and their number
	log.Printf("There are %d non-SSL NodePorts in the cluster\n", len(result.Hosts[0].Ports))
	os.Exit(len(result.Hosts[0].Ports))
}
