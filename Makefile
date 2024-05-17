TOOLBOX_BINARY=toolboxApp
## build_broker: builds the toolbox binary as a linux executable
.PHONY: build_all
build_all:
	@echo "Building toolbox binary..."
	@go test -coverprofile cover.out -v ./
	@env GOOS=linux CGO_ENABLED=0 go build -o bin/${TOOLBOX_BINARY} .
	@echo "Done!"

## test: executes tests
.PHONY: test
test:
	@echo "Testing toolbox application..."
	@go test -coverprofile cover.out -v ./

## Create test coverage report
.PHONY: testreport
testreport:
	@echo "Generating test report..."
	@go tool cover -html=cover.out