# FROM registry.redhat.io/rhel9/go-toolset
FROM registry.access.redhat.com/ubi9/ubi as builder
RUN dnf -y install 'dnf-command(config-manager)' && dnf config-manager --enable crb
RUN dnf -y --setopt=install_weak_deps=0 install \
  cargo pkg-config perl-FindBin openssl-devel perl-lib perl-IPC-Cmd perl-File-Compare perl-File-Copy clang-devel \
  # These two are only available in the CodeReady Builder repo.
  tpm2-tss-devel protobuf-compiler \
  # This one is needed to build the stub.
  meson golang


RUN mkdir /build
WORKDIR /build
RUN pwd
COPY hello.go .
COPY go.mod .
COPY hello_test.go .

# run tests
RUN go test

# build
RUN go build

# copy binary to clean image
FROM registry.access.redhat.com/ubi9/ubi
COPY --from=builder /build/hello /usr/bin/hello
