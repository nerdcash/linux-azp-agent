# Inspired by https://github.com/MicrosoftDocs/azure-devops-docs/blob/main/docs/pipelines/agents/docker.md#linux
FROM ubuntu:22.04
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".
 
ENV HasDockerAccess="true"
 
RUN apt-get update \
	&& apt-get upgrade -y
RUN apt-get install -y \
        curl \
        git \
        jq \
        libicu70 \
        build-essential \
        wget \
        apt-transport-https \
        software-properties-common \
	squashfs-tools \
	unzip \
	android-sdk sdkmanager android-sdk-helper \
	docker.io
 
ENV ANDROID_SDK_ROOT=/usr/lib/android-sdk
RUN sdkmanager --install 'platforms;android-34'
 
# Install Powershell
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
        && dpkg -i packages-microsoft-prod.deb \
        && rm packages-microsoft-prod.deb \
        && apt-get update \
        && apt-get install -y powershell
 
# Get Rust; NOTE: using sh for better compatibility with other base images
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
 
# Add tools to the PATH
ENV PATH="/root/.cargo/bin:${PATH}"
 
# cargo binstall saves a lot of time when installing tools, but binstall itself takes a long time, so do it within the image.
RUN cargo install cargo-binstall --locked
 
WORKDIR /azp/
 
COPY ./start.sh ./multi-start.sh ./
RUN chmod +x ./start.sh ./multi-start.sh
 
ENV AGENT_ALLOW_RUNASROOT="true"
 
ENTRYPOINT [ "./multi-start.sh" ]
 
