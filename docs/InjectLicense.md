Inject a License into the Pitch CRC Image
=====================================

By injecting the license key into the image itself, the license becomes part of the Pitch CRC image. There is no need to refer to a license server or use a license container.

To do this, perform the following steps.

## Create build directory and environment settings file

This is the same step as in [Create a Pitch License Container](CreateLicenseImage.md).

## Set LICENSE environment variable

This is the same step as in [Create a Pitch License Container](CreateLicenseImage.md).

Inject license and create new image
----------------------

Execute the following commands from a shell. Note that a new image is committed with `docker commit` and tagged with the additional letter `L` to indicate that this image includes a license key.

````
# source the environment variables
source .env

# inject license
docker run \
	--mac-address=${MAC_ADDRESS} \
	--name crc \
	${REPOSITORY}pitch-crc:${PITCH_VERSION} -l ${LICENSE}

# commit as a new image
docker commit -c 'ENTRYPOINT ["/bin/sh", "./start.sh"]' crc ${REPOSITORY}pitch-crc:${PITCH_VERSION}L

# clean up
docker rm crc
````

## Run the licensed Pitch CRC

In this final step we show how to run the licensed Pitch CRC container. Create the following ``docker-compose.yml`` file:

```
version: '3'

services:
 crc:
  image: ${REPOSITORY}pitch-crc:${PITCH_VERSION}L
  mac_address: ${MAC_ADDRESS}
  environment:
  - DISPLAY=${DISPLAY}
  ports:
  - "8989:8989"
```

Start the composition with ``docker-compose up`` and verify in the Pitch CRC UI that the correct number of licenses is set.

