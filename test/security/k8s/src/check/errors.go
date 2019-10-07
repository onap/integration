package check

import (
	"errors"
)

var (
	// ErrNotImplemented is returned when function is not implemented yet.
	ErrNotImplemented = errors.New("function not implemented")
)
