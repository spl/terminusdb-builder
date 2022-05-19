FROM debian:bullseye-slim

LABEL maintainer "TerminusDB Team <team@terminusdb.com>"

# Variables that will never change
ENV LANG=C.UTF-8 \
    npm_config_cache=/tmp/npm-cache \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
ENV PATH=${CARGO_HOME}/bin:$PATH

# Node.js and Cog configuration
ENV NODE_VERSION=16 \
    COG_VERSION=3.3.0

# Install build and development dependencies
RUN set -eux; \
    apt-get update; \
    # Install most package dependendencies
    apt-get install -y --no-install-recommends \
        autoconf \
        ca-certificates \
        clang \
        cmake \
        curl \
        g++ \
        gcc \
        git \
        libarchive-dev \
        libarchive13 \
        libedit-dev \
        libedit2 \
        libgmp-dev \
        libgmp10 \
        libgoogle-perftools-dev \
        libncurses6 \
        libossp-uuid-dev \
        libossp-uuid16 \
        libpcre3 \
        libpcre3-dev \
        libreadline-dev \
        libssl-dev \
        libssl1.1 \
        libtcmalloc-minimal4 \
        make \
        ninja-build \
        nodejs \
        python3 \
        python3-pip \
        zlib1g-dev; \
    # Install Node.js
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*; \
    # Make the npm cache world-readable
    # <https://stackoverflow.com/q/14836053>
    mkdir -p ${npm_config_cache}; \
    chmod a+w ${npm_config_cache}; \
    # Install Cog
    pip install cogapp==${COG_VERSION}; \
    # Report versions
    node --version; \
    npm --version; \
    python3 --version; \
    pip --version; \
    cog -v

# SWI-Prolog configuration. See <https://github.com/SWI-Prolog/docker-swipl>.
ENV SWIPL_VERSION=8.4.2 \
    SWIPL_CHECKSUM=be21bd3d6d1c9f3e9b0d8947ca6f3f5fd56922a3819cae03251728f3e1a6f389

# Instal SWI-Prolog
RUN set -eux; \
    SWIPL_SRC=swipl-${SWIPL_VERSION}; \
    curl -fsSLO "http://www.swi-prolog.org/download/stable/src/${SWIPL_SRC}.tar.gz"; \
    echo "${SWIPL_CHECKSUM} *${SWIPL_SRC}.tar.gz" | sha256sum -c -; \
    tar -xzf ${SWIPL_SRC}.tar.gz; \
    mkdir ${SWIPL_SRC}/build; \
    cd ${SWIPL_SRC}/build; \
    cmake .. \
        -DCMAKE_BUILD_TYPE=PGO \
        -DSWIPL_PACKAGES_X=OFF \
        -DSWIPL_PACKAGES_JAVA=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DINSTALL_DOCUMENTATION=OFF \
        -DSWIPL_PACKAGES_ODBC=OFF \
        -G Ninja; \
    ninja; \
    ninja install; \
    cd -; \
    rm -r ${SWIPL_SRC}.tar.gz ${SWIPL_SRC}; \
    mkdir -p /usr/lib/swipl/pack; \
    # Report version
    swipl --version

# Rust configuration. See <https://github.com/rust-lang/docker-rust>.
ENV RUSTUP_VERSION=1.24.3 \
    RUSTUP_CHECKSUM=3dc5ef50861ee18657f9db2eeb7392f9c2a6c95c90ab41e45ab4ca71476b4338 \
    RUST_TOOLCHAIN=1.60.0

# Install Rust
RUN set -eux; \
    # Install rustup-init
    curl -fsSLO "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/x86_64-unknown-linux-gnu/rustup-init"; \
    echo "${RUSTUP_CHECKSUM} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    # Install rustup, rustc, and cargo
    ./rustup-init -y --no-modify-path --profile=minimal; \
    rm rustup-init; \
    chmod -R a+w ${RUSTUP_HOME} ${CARGO_HOME}; \
    # Report versions
    rustup --version; \
    cargo --version; \
    rustc --version

# [DO THIS LAST]
#
# Update to the latest crates.io index to save time for users of this image.
#
# This attempts to install an executable from the lazy_static crate. However,
# this crate does not have an executable and will cause the install to fail, but
# the failure only happens after the index is updated.
RUN cargo install lazy_static 2> /dev/null || true

WORKDIR /app/terminusdb

CMD ["/bin/bash"]
