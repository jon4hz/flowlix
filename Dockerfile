FROM fedora:44 AS build

ARG JUCE_TAG=5.4.7

RUN dnf -y install \
      gcc-c++ make git patch pkgconf-pkg-config \
      libX11-devel libXext-devel libXinerama-devel libXrandr-devel \
      libXcursor-devel libXcomposite-devel \
      freetype-devel libcurl-devel libusb1-devel alsa-lib-devel && \
    dnf clean all

WORKDIR /src

# JUCE must sit beside the app: the Makefile references ../../../JUCE/modules
RUN git clone --depth 1 --branch "${JUCE_TAG}" \
      https://github.com/juce-framework/JUCE.git JUCE

# App source comes from the git submodule in the build context.
COPY external/FlowtoysUpdater /src/FlowtoysUpdater
COPY patches /patches

# Apply the tracked patches (git-diff format, applied with plain `patch`).
RUN cd /src/FlowtoysUpdater && \
    for p in /patches/*.patch; do echo ">> applying $p"; patch -p1 < "$p"; done

# Compile (Release; the Makefile is patched to -O1, see patches/0005) and stage
# a stripped binary.
RUN cd /src/FlowtoysUpdater/Builds/LinuxMakefile && \
    make CONFIG=Release -j"$(nproc)" && \
    mkdir -p /out && \
    cp build/FlowtoysUpdater /out/FlowtoysUpdater && \
    strip /out/FlowtoysUpdater

# Minimal stage so `--output` writes just the binary to the host.
FROM scratch AS artifact
COPY --from=build /out/FlowtoysUpdater /FlowtoysUpdater
