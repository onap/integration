rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $2,$d))

.PHONY: test
test: $(patsubst %.test,%.stdout,$(call rwildcard,,%.test))

%.stdout: %.test
	./$< > $@ 2> $(patsubst %.stdout,%.stderr,$@) \
		|| (touch --date=@0 $@; false)
	git diff --exit-code --src-prefix=expected/ --dst-prefix=actual/ \
		$@ $(patsubst %.stdout,%.stderr,$@) \
		|| (touch --date=@0 $@; false)

