TOOLBOX_BINARY=toolboxApp
export GOBIN ?= $(shell pwd)/bin

GO_FILES := $(shell \
	find . '(' -path '*/.*' -o -path './vendor' ')' -prune \
	-o -name '*.go' -print | cut -b3-)

GOLINT = $(GOBIN)/golint
STATICCHECK = $(GOBIN)/staticcheck

## build_broker: builds the toolbox binary as a linux executable
build_all: test lint scan
	@echo "Building toolbox binary..."
	@env GOOS=linux CGO_ENABLED=0 buildutil --build --output bin/${TOOLBOX_BINARY} --withLDFlags
	@echo "Done!"

## test: executes tests
test:
	@echo "Testing toolbox application..."
	@go test -coverprofile cover.out -v ./

## Create test coverage report
testreport:
	@echo "Generating test report..."
	@go tool cover -html=cover.out

## Vulnerability scanning
scan:
	@echo "Doing vulnerability scanning"
	@govulncheck ./...

## Download required modules.
install:
	go mod download

$(GOLINT): tools/go.mod
	cd tools && go install golang.org/x/lint/golint

$(STATICCHECK): tools/go.mod
	cd tools && go install honnef.co/go/tools/cmd/staticcheck@2025.1

lint: install $(GOLINT) $(STATICCHECK)
	@rm -rf lint.log
	@echo "Checking gofmt"
	@gofmt -d -s $(GO_FILES) 2>&1 | tee lint.log
	@echo "Checking go vet"
	@go vet ./... 2>&1 | tee -a lint.log
	@echo "Checking golint"
	@$(GOLINT) ./... | tee -a lint.log
	@echo "Checking staticcheck"
	@$(STATICCHECK) ./... 2>&1 |  tee -a lint.log
	@echo "Checking for license headers..."
	@./.build/check_license.sh | tee -a lint.log
	@[ ! -s lint.log ]


.PHONY: build_all lint install test scan testreport