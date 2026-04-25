FROM docker.io/library/node:20-slim

ARG SANDBOX_NAME="gemini-cli-sandbox"
ARG CLI_VERSION_ARG
ENV SANDBOX="$SANDBOX_NAME"
ENV CLI_VERSION=$CLI_VERSION_ARG

# install minimal set of packages, then clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 \
  python3-pip \
  python3-venv \
  python-is-python3 \
  r-base \
  r-base-dev \
  make \
  g++ \
  man-db \
  curl \
  dnsutils \
  less \
  jq \
  bc \
  gh \
  git \
  unzip \
  rsync \
  ripgrep \
  procps \
  psmisc \
  lsof \
  socat \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configure R
RUN mkdir -p /usr/lib/R/etc \
  && echo 'options(repos = c(CRAN = "https://p3m.dev/cran/__linux__/bookworm/latest"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site

# Install uv
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then UV_ARCH="x86_64-unknown-linux-musl"; elif [ "$ARCH" = "aarch64" ]; then UV_ARCH="aarch64-unknown-linux-musl"; else echo "Unsupported arch: $ARCH"; exit 1; fi && \
    curl -LsSf https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}.tar.gz -o /tmp/uv.tar.gz && \
    tar -xzf /tmp/uv.tar.gz -C /tmp && \
    mv /tmp/uv-${UV_ARCH}/uv* /usr/local/bin/ && \
    rm -rf /tmp/uv.tar.gz /tmp/uv-${UV_ARCH}

# Install DuckDB
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then DUCKDB_ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then DUCKDB_ARCH="arm64"; else echo "Unsupported arch: $ARCH"; exit 1; fi && \
    curl -LsSf https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-${DUCKDB_ARCH}.zip -o /tmp/duckdb.zip && \
    unzip /tmp/duckdb.zip -d /usr/local/bin && \
    rm /tmp/duckdb.zip && \
    chmod +x /usr/local/bin/duckdb

# set up npm global package folder under /usr/local/share
# give it to non-root user node, already set up in base image
RUN mkdir -p /usr/local/share/npm-global \
  && chown -R node:node /usr/local/share/npm-global
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# switch to non-root user node
USER node

# install gemini-cli and clean up
COPY --chown=node:node packages/cli/dist/google-gemini-cli-*.tgz /tmp/gemini-cli.tgz
COPY --chown=node:node packages/core/dist/google-gemini-cli-core-*.tgz /tmp/gemini-core.tgz
RUN npm install -g /tmp/gemini-core.tgz \
  && npm install -g /tmp/gemini-cli.tgz \
  && node -e "const fs=require('node:fs'); JSON.parse(fs.readFileSync('/usr/local/share/npm-global/lib/node_modules/@google/gemini-cli/package.json','utf8')); JSON.parse(fs.readFileSync('/usr/local/share/npm-global/lib/node_modules/@google/gemini-cli-core/package.json','utf8'));" \
  && gemini --version > /dev/null \
  && npm cache clean --force \
  && rm -f /tmp/gemini-{cli,core}.tgz

# default entrypoint when none specified
CMD ["gemini"]
