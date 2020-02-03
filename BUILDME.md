# Build the Pitch CRC image

The Pitch CRC image can be built with the Pitch RTI installer from Pitch, or with the placeholder installer that is already present in this repository.

In the first case the Pitch RTI files are installed in the image and - when built - the image is ready to run.

In the second case only a skeleton directory structure and some necessary (but empty) files are created in the image. No Pitch files are installed in the image and the files from the Pitch RTI installer must be mounted into the CRC container afterwards in order to create a functional CRC container.

Both options are described below.

## Build CRC image with the Pitch RTI installer

Perform the following steps to build the Pitch CRC image with the RTI installer from Pitch.

### Obtain the Pitch RTI installer

This repository does not contain the Pitch RTI installer due to license restrictions. The first step is to obtain the installer and licenses from Pitch, see http://www.pitchtechnologies.com. A free RTI version for two federates can be obtained from this site also.

### Clone repository and drop in Pitch RTI installer

Clone this Git repository to the directory named `${WORKDIR}`.

Copy the Pitch RTI installer into the directory `${WORKDIR}/pitch-crc/docker/context` and remove the placeholder installer that is already there. The name of the Pitch RTI installer is for example `prti1516e-free_5_4_5_0_linux64_b182.sh`.

Note the version number `free_5_4_5_0` in the file name.

### Build image

Change into the directory `${WORKDIR}/pitch-crc/docker`.

Check and if needed adapt the environment variable settings in the file `.env`. For example, set the version number.

Next, build the CRC container image with:

````
docker-compose -f build.yml build
````

## Build skeleton CRC image with the placeholder installer

Perform the following steps to build a skeleton Pitch CRC image with the placeholder installer. Note again that the resulting image is not executable since the Pitch files are missing. These files need to be mounted in the container.

### Clone repository

Clone this Git repository to the directory named `${WORKDIR}`.

### Build image

Change into the directory `${WORKDIR}/pitch-crc/docker`.

Check and if needed adapt the environment variable settings in the file `.env`. For example, set the version number.

Next, build the **skeleton** CRC container image with:

````
docker-compose -f build.yml build
````

### Run skeleton CRC container

An example on how to run the skeleton Pitch CRC container is provided under the examples directory in this repository. We assume in the example that the Pitch RTI (including the CRC) is installed on the host filesystem under the directory `RTI_HOME`. The directory `RTI_HOME` is mounted into the skeleton CRC container to create a functional CRC container, as shown in the composition below:

````
version: '3'

services: 
 xserver:
  image: ${REPOSITORY}xserver
  ports:
  - "8080:8080"
  
 crc:
  image: ${REPOSITORY}pitch-crc:${PITCH_VERSION}
  mac_address: ${MAC_ADDRESS}
  environment:
  - DISPLAY=${DISPLAY}
  ports:
  - "8989:8989"
````

