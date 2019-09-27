package controllermanager_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestControllermanager(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Controllermanager Suite")
}
