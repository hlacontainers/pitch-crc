# Build the Pitch CRC image

The Pitch CRC image can be built with the **Pitch RTI installer** from Pitch, or with the **skeleton installer** that is already present in this repository.

In the first case the Pitch RTI files are installed in the image and - when built - the image is ready to run.

In the second case only a skeleton directory structure and some necessary (but empty) files are created in the image. No Pitch files are installed in the image and the files from the Pitch RTI installer must be mounted into the CRC container afterwards in order to create a functional CRC container.

Both options are described below.

Tested Pitch RTI versions:

- `free_5_4_5_0`
- `5_4_5_0`
- `5_5_0_0`

## Build CRC image with the Pitch RTI installer

Perform the following steps to build the Pitch CRC image with the RTI installer from Pitch.

### Obtain the Pitch RTI installer

This repository does not contain the Pitch RTI installer due to license restrictions. The first step is to obtain the installer and licenses from Pitch, see http://www.pitchtechnologies.com. A free RTI version for two federates can be obtained from this site also.

### Clone repository and drop in Pitch RTI installer

Clone this Git repository to the directory named `${WORKDIR}`.

Copy the Pitch RTI installer into the directory `${WORKDIR}/pitch-crc/docker/context`. The name of the Pitch RTI installer for Pitch RTI version `<version>` must match with `prti1516e*<version>*linux64*.sh`, for example `prti1516e-free_5_4_5_0_linux64_b182.sh`.

Note the Pitch RTI version number in the file name, in this example `free_5_4_5_0`.

### Build image

Change into the directory `${WORKDIR}/pitch-crc/docker`.

Edit the file `.env` and set the Pitch RTI version number noted before.

Next, build the **complete** CRC container image with:

````
docker-compose -f build.yml build
````

The name of the resulting image is:

````
hlacontainers/pitch-crc:<version>
````

## Build skeleton CRC image with the skeleton installer

Perform the following steps to build a skeleton Pitch CRC image with the skeleton installer. Note again that the resulting image is not executable since the Pitch files are missing. These files need to be mounted in the container.

### Clone repository

Clone this Git repository to the directory named `${WORKDIR}`.

### Build image

Change into the directory `${WORKDIR}/pitch-crc/docker`.

Build the **skeleton** CRC container image with:

````
docker-compose -f build.yml build
````

The name of the resulting image is:

````
hlacontainers/pitch-crc:skeleton
````

