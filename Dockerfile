# Copyright 2020 Matt Budish

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# cpp-devtools-base
#
# A base set of tools for building modular C++ apps

FROM centos:8 AS devtools

LABEL maintainer="Matt Budish <mtbudish@gmail.com>"

ARG NINJA_VERSION=v1.10.0

ENV NINJA_URL=https://github.com/ninja-build/ninja/releases/download/${NINJA_VERSION}/ninja-linux.zip

ARG ORACLE_MAJ=19
ARG ORACLE_MIN=6

ENV OIC_BASE=https://download.oracle.com/otn_software/linux/instantclient/${ORACLE_MAJ}${ORACLE_MIN}00/
ENV OIC_BASIC=oracle-instantclient${ORACLE_MAJ}.${ORACLE_MIN}-basic-${ORACLE_MAJ}.${ORACLE_MIN}.0.0.0-1.x86_64.rpm
ENV OIC_BASIC_URL=${OIC_BASE}${OIC_BASIC}
ENV OIC_SDK=oracle-instantclient${ORACLE_MAJ}.${ORACLE_MIN}-devel-${ORACLE_MAJ}.${ORACLE_MIN}.0.0.0-1.x86_64.rpm
ENV OIC_SDK_URL=${OIC_BASE}${OIC_SDK}

WORKDIR /opt/tools/

# Install all the things.
RUN dnf -y update && \
    dnf -y install \
        binutils \
        boost-devel \
        curl \
        gcc-c++ \
        git \
        libnsl \
        make \
        openssl-devel \
        python36 \
        python3-pip \
        unzip && \
    dnf -y --enablerepo=PowerTools install \
        boost-static && \
    curl -sLO ${OIC_BASIC_URL} && \
    curl -sLO ${OIC_SDK_URL} && \
    dnf -y install ${OIC_BASIC} && \
    dnf -y install ${OIC_SDK} && \
    dnf clean all && \
    rm ${OIC_BASIC} && \
    rm ${OIC_SDK} && \
    # A link to `libocci.so.${ORACLE_MAJ}.1` is needed as it apparently got missed in the RPM.
    ln -s /usr/lib/oracle/${ORACLE_MAJ}.${ORACLE_MIN}/client64/lib/libocci.so.${ORACLE_MAJ}.1 \
        /usr/lib/oracle/${ORACLE_MAJ}.${ORACLE_MIN}/client64/lib/libocci.so && \
    # Install a newer version of Ninja than what is available in RPM.
    curl -sL ${NINJA_URL} | funzip > /usr/local/bin/ninja && \
    chmod +x /usr/local/bin/ninja && \
    pip3 install --upgrade pip && \
    # Install a newer version of CMake than what is available in RPM.
    pip install cmake && \
    # Install vcpkg
    git clone --single-branch -b cmsdk https://github.com/mattbudish/vcpkg.git && \
    vcpkg/bootstrap-vcpkg.sh --useSystemBinaries

CMD [ "g++", "--version" ]