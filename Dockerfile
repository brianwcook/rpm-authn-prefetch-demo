# FROM registry.redhat.io/rhel9/go-toolset
FROM registry.access.redhat.com/ubi9/ubi as builder

RUN dnf -y --setopt=install_weak_deps=0 install \
  cargo pkg-config perl-FindBin openssl-devel perl-lib perl-IPC-Cmd perl-File-Compare perl-File-Copy clang-devel \
  tpm2-tss-devel protobuf-compiler meson golang

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
