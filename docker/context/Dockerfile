#
# Copyright 2020 Tom van den Berg (TNO, The Netherlands).
# SPDX-License-Identifier: Apache-2.0
#

# Set default for build-time ARGs
ARG PITCH_VERSION=free_5_4_5_0

#########################
# Create Base image
#########################
FROM ubuntu:16.04 AS base

ARG PITCH_VERSION

# Install required font-related packages for install4j
RUN apt-get update && apt-get install -y libfreetype6 libfontconfig

# Set the RTI_HOME
ENV RTI_HOME=/usr/local/prti1516e

# Copy and run the pRTI Linux installer
COPY ./prti1516e-${PITCH_VERSION}_linux64_*.sh /tmp/
RUN sh $(ls /tmp/*.sh) -q -d ${RTI_HOME}

# Ensure there is a skeleton structure
RUN mkdir -p ${RTI_HOME}/bin ${RTI_HOME}/include ${RTI_HOME}/jre ${RTI_HOME}/lib ${RTI_HOME}/.install4j /root/prti1516e
RUN touch /root/prti1516e/prti1516eLRC.settings /root/prti1516e/prti1516e.logging

#########################
# Create CRC image
#########################
FROM ubuntu:16.04

# Get packages that we need to run the CRC GUI
RUN apt-get update && apt-get install -y libfreetype6 libfontconfig libxext6 libxrender1 libxtst6 libxi6 netcat

# Set the RTI_HOME
ENV RTI_HOME=/usr/local/prti1516e

# Create a smaller image by only using the relevant items from base
COPY --from=base ${RTI_HOME}/bin/			${RTI_HOME}/bin/
COPY --from=base ${RTI_HOME}/include/		${RTI_HOME}/include/
COPY --from=base ${RTI_HOME}/jre/			${RTI_HOME}/jre/
COPY --from=base ${RTI_HOME}/lib/			${RTI_HOME}/lib/
COPY --from=base ${RTI_HOME}/.install4j/	${RTI_HOME}/.install4j/
COPY --from=base /root/prti1516e/			/root/prti1516e/

# Install start script
COPY ./start.sh /root

# Set entrypoint
WORKDIR /root
ENTRYPOINT ["/bin/sh", "./start.sh"]

# Port 1099 is the RMI registry port. The CRC opens this port and listens for connections from the Pitch Web UI.
EXPOSE 1099/tcp

# Port 8989 is where CRC accepts connections from federates.
EXPOSE 8989/tcp
