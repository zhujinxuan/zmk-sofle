# ZMK Firmware Local Build Environment
# Using 毫秒云 (docker.1ms.run) mirror for Docker Hub access

# Use 毫秒云 mirror for Ubuntu base image
FROM docker.1ms.run/library/ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    wget \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    xz-utils \
    file \
    make \
    gcc \
    gcc-multilib \
    g++-multilib \
    libsdl2-dev \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    west \
    pyelftools \
    pyyaml

# Set up working directory
WORKDIR /workspace

# Install Zephyr SDK
# Using Huawei Cloud mirror or direct download
RUN wget -q https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/zephyr-sdk-0.16.5_linux-x86_64.tar.xz \
    && tar xvf zephyr-sdk-0.16.5_linux-x86_64.tar.xz -C /opt/ \
    && rm zephyr-sdk-0.16.5_linux-x86_64.tar.xz \
    && /opt/zephyr-sdk-0.16.5/setup.sh -t all -h -c

# Set environment variables for Zephyr SDK
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-0.16.5
ENV PATH="${ZEPHYR_SDK_INSTALL_DIR}/sysroots/x86_64-pokysdk-linux/usr/bin:${PATH}"

# Clone ZMK repository
# Using gitee mirror for China access (alternative to GitHub)
RUN git clone --depth 1 https://gitee.com/mirrors/zmk.git /workspace/zmk

# Initialize west workspace
WORKDIR /workspace/zmk/app
RUN west init -l /workspace/zmk || true
RUN west update

# Set up build scripts
COPY build.sh /workspace/build.sh
COPY build-wsl.sh /workspace/build-wsl.sh
RUN chmod +x /workspace/build.sh /workspace/build-wsl.sh

# Set the entrypoint (can be overridden)
ENTRYPOINT ["/workspace/build.sh"]
CMD []
