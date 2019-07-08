package master_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestMaster(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Master Suite")
}
