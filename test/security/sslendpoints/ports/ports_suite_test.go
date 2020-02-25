package ports_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestNodeports(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Nodeports Suite")
}
