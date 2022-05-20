FROM terminusdb/swipl:v8.4.2

LABEL maintainer "TerminusDB Team <team@terminusdb.com>"

# Variables that will never change
ENV LANG=C.UTF-8 \
    npm_config_cache=/tmp/npm-cache \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
ENV PATH=${CARGO_HOME}/bin:$PATH

# Package dependencies
#
# Each env var here should be specified independently (as if there were no other
# packages installed). This makes it easier to change the them in the future.
# apt-get doesn't care if there are duplicates.
ENV COG_DEPS \
        python3 \
        python3-pip
ENV NODE_DEPS \
        curl
ENV TERMINUSDB_DEPS \
        build-essential \
        clang \
        curl \
        git \
        libjwt-dev \
        libssl-dev \
        make \
        pkg-config

# Install most dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ${COG_DEPS} \
        ${NODE_DEPS} \
        ${TERMINUSDB_DEPS}; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/apt/*; \
    # Report versions
    python3 --version; \
    pip --version

# Cog configuration
ENV COG_VERSION=3.3.0

# Install Cog
RUN set -eux; \
    pip install cogapp==${COG_VERSION}; \
    # Report version
    cog -v

# Node.js configuration
ENV NODE_VERSION=16

# Install Node.js
RUN set -eux; \
    # Install Node.js
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*; \
    # Make the npm cache world-readable
    # <https://stackoverflow.com/q/14836053>
    mkdir -p ${npm_config_cache}; \
    chmod a+w ${npm_config_cache}; \
    # Report versions
    node --version; \
    npm --version

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
