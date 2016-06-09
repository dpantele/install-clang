FROM        buildpack-deps:xenial-scm

# Setup environment.
ENV PATH /opt/llvm/bin:$PATH

# Default command on startup.
CMD bash

# Setup packages.
RUN apt-get update \
  && apt-get install -y \
    build-essential \
    ninja-build \
    python \
    vim \
  && rm -rf /var/lib/apt/lists/*

# install new cmake
# from a binary package
# verification is performed for integrity, not security reasons
ENV CMAKE_VERSION=3.5.2
ENV CMAKE_VERSION_MAJOR=3.5
RUN cd /tmp \
  && curl -L https://cmake.org/files/v$CMAKE_VERSION_MAJOR/cmake-$CMAKE_VERSION-Linux-x86_64.sh > cmake-$CMAKE_VERSION-Linux-x86_64.sh \
  && (echo "2999af0a9e0f8173fe84a494e8a7e183e81c3e57e95c0d867aa1c76af0269760  cmake-$CMAKE_VERSION-Linux-x86_64.sh" \
    | sha256sum --check --status --strict -) \
  && sh cmake-$CMAKE_VERSION-Linux-x86_64.sh --exclude-subdir --prefix=/usr/local --skip-license \
  && rm cmake-$CMAKE_VERSION-Linux-x86_64.sh

# Copy install-clang over.
ADD . /opt/install-clang

ARG build_workers=4

# Compile and install LLVM/clang. We delete the source directory to
# avoid committing it to the image.
RUN /opt/install-clang/install-clang -j $build_workers -C /opt/llvm


