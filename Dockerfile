FROM ubuntu:latest
LABEL maintainer "Perfection <perfection@lighthouse.storage>"

# update apt and install dependencies
RUN apt-get update && \ 
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# download and extract ipfs
RUN wget https://dist.ipfs.io/kubo/v0.14.0/kubo_v0.14.0_linux-386.tar.gz && \
    tar xvfz kubo_v0.14.0_linux-386.tar.gz && \
    mv kubo/ipfs /usr/local/bin/ && \
    rm kubo_v0.14.0_linux-386.tar.gz && \
    rm -rf kubo

# checkpoint --- echo ipfs version
RUN ipfs version
ENV IPFS_PATH /data/ipfs

ENV API_PORT 5002
ENV GATEWAY_PORT 8080
ENV SWARM_PORT 4001

EXPOSE ${SWARM_PORT}
# This may introduce security risk to expose API_PORT public
# EXPOSE ${API_PORT}
EXPOSE ${GATEWAY_PORT}

RUN mkdir -p ${IPFS_PATH} 

# no need to for this as docker runs in root user mode
# RUN chown ubuntu:ubuntu ${IPFS_PATH}

# configure ipfs for production
RUN ipfs init -p server && \
    ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080 && \
    ipfs config --json Datastore.BloomFilterSize 1048576 && \
    ipfs config --json Datastore.StorageGCWatermark 60 && \
    ipfs config Datastore.StorageMax 4GB && \
    ipfs config Datastore.GCPeriod "60s" && \
    ipfs config Reprovider.Interval "0" && \
    ipfs config Routing.Type none

ENTRYPOINT ipfs daemon --enable-gc