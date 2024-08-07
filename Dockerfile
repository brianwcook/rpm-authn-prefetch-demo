# FROM registry.redhat.io/rhel9/go-toolset
FROM registry.access.redhat.com/ubi9/ubi as builder
# kernel devel is unnecessary but it requires entitlement, added as example
#RUN \
#    # Enable additional repositories for CentOS or RHEL.
#    REPO_ARCH=$(uname -m) && \
#    dnf repolist all && \
#    dnf -y --setopt=install_weak_deps=0 install \
#        --enablerepo=rhel-9-for-${REPO_ARCH}-appstream-rpms,codeready-builder-for-rhel-9-${REPO_ARCH}-rpms \
#        cargo pkg-config perl-FindBin openssl-devel perl-lib perl-IPC-Cmd perl-File-Compare perl-File-Copy clang-devel \
#        # These two are only available in the CodeReady Builder repo.
#        tpm2-tss-devel protobuf-compiler \
#        # This one is needed to build the stub. 
#        meson \
#        # this is for my [bcook] go build 
#        golang 

RUN \
# Enable additional repositories for CentOS or RHEL.
#if command -v subscription-manager; then \
#  subscription-manager register --org $(cat "/activation-key/orgid") \
#    --activationkey $(cat "/activation-key/activationkey") && \
#  REPO_ARCH=$(uname -m) && \
#  dnf repolist all && \
#  subscription-manager repos --list && \
#  subscription-manager repos --enable rhel-9-for-${REPO_ARCH}-appstream-rpms --enable codeready-builder-for-rhel-9-${REPO_ARCH}-rpms; \
#else \
  dnf -y install 'dnf-command(config-manager)' && dnf config-manager --enable crb; \
fi && \
# Install packages.
dnf -y --setopt=install_weak_deps=0 install \
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
