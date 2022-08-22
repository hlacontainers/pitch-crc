# Build the Pitch CRC image

The Pitch CRC image must be built with the **Pitch RTI installer** from Pitch. Perform the following steps to build the Pitch CRC image with the RTI installer from Pitch.

## Obtain the Pitch RTI installer

This repository does not contain the Pitch RTI installer due to license restrictions. The first step is to obtain the installer and licenses from Pitch, see http://www.pitchtechnologies.com. A free RTI version for two federates can be obtained from this site also.

## Clone repository and drop in Pitch RTI installer

Clone this Git repository to the directory named `${WORKDIR}`.

Copy the Pitch RTI installer into the directory `${WORKDIR}/pitch-crc/docker/context`. The name of the Pitch RTI installer for Pitch RTI version `<version>` must match with `prti1516e*<version>*linux64*.sh`, for example `prti1516e_5_5_5_linux64.sh`.

Note the Pitch RTI version number in the file name, in this example `5_5_5`.

## Build image

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

