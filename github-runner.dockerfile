# Inspired by https://github.com/MicrosoftDocs/azure-devops-docs/blob/main/docs/pipelines/agents/docker.md#linux

FROM ubuntu:24.04
ENV TARGETARCH="linux-x64"
ENV HasDockerAccess="true"

# Update and install base dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        curl \
        git \
        jq \
        build-essential \
        wget \
        apt-transport-https \
        software-properties-common \
        squashfs-tools \
        unzip \
        openjdk-17-jdk \
        libwebkit2gtk-4.1-dev \
        libappindicator3-dev \
        librsvg2-dev \
        patchelf \
        libfuse2 \
        docker.io \
        sudo && \
    rm -rf /var/lib/apt/lists/*

# Install Android SDK Command-line Tools from Google
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    mkdir -p /opt/android/cmdline-tools/latest && \
    unzip cmdline-tools.zip -d /opt/android/cmdline-tools/latest && \
    rm cmdline-tools.zip && \
    # Move contents so sdkmanager is in latest/bin
    mv /opt/android/cmdline-tools/latest/cmdline-tools/* /opt/android/cmdline-tools/latest/ && \
    rm -rf /opt/android/cmdline-tools/latest/cmdline-tools

# Set environment variables for Android SDK
ENV ANDROID_HOME=/opt/android
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

# Accept licenses and install platform tools
RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses && \
    sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "platforms;android-34"

# Install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    rm -rf /var/lib/apt/lists/*

# Create non-root runner user (GitHub Runner refuses to run as root)
RUN addgroup --gid 1001 runner && \
    adduser --uid 1001 --gid 1001 --disabled-password --gecos "" runner && \
    usermod -aG docker runner && \
    echo 'runner ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER runner
WORKDIR /home/runner/

COPY --chown=runner:runner ./start.sh ./multi-start.sh ./
RUN chmod +x ./start.sh ./multi-start.sh

# Get Rust; NOTE: using sh for better compatibility with other base images
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Add Rust tools to PATH
ENV PATH="/home/runner/.cargo/bin:${PATH}"

# Install cargo-binstall for faster Rust tool installation
RUN cargo install cargo-binstall --locked

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENTRYPOINT [ "./multi-start.sh" ]
