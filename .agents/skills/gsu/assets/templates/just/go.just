fmt:
  gofmt -w .

lint:
  GOCACHE="$PWD/.local/go-build" GOMODCACHE="$PWD/.local/go-mod" go vet ./...

typecheck:
  GOCACHE="$PWD/.local/go-build" GOMODCACHE="$PWD/.local/go-mod" go test ./... -run '^$'

build:
  mkdir -p .local/bin
  GOCACHE="$PWD/.local/go-build" GOMODCACHE="$PWD/.local/go-mod" go build -o .local/bin/app .

test target="./...":
  GOCACHE="$PWD/.local/go-build" GOMODCACHE="$PWD/.local/go-mod" go test {{target}}

docs:
  GOCACHE="$PWD/.local/go-build" GOMODCACHE="$PWD/.local/go-mod" go doc ./...

smoke:
  GOCACHE="$PWD/.local/go-build" GOMODCACHE="$PWD/.local/go-mod" go run .

diff-check:
  git diff --check

verify: fmt lint typecheck build test smoke diff-check
