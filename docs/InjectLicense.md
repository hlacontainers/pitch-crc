Inject a License into the Pitch CRC Image
=====================================

By injecting the license key into the image itself, the license becomes part of the Pitch CRC image. There is no need to refer to a license server or use a license container.

To do this, perform the following steps.

## Create build directory and environment settings file

Prepare a `builddir` with a `.env` file in it:

````Ada
mkdir builddir

cd builddir

# Change the following environment values to match your license key:
cat << EOF >> .env
REPOSITORY=hlacontainers/
PITCH_VERSION=5_5_0_0
MAC_ADDRESS=00:18:8B:0D:4F:0B
DISPLAY=xserver:0
EOF
````

The value for the MAC address above is an example. Adapt the value of `MAC_ADDRESS` to a value that matches with the license key. Optionally set the value of `DISPLAY` to an X Display. This setting is used later to run the Pitch CRC container with an X Display.

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
	${REPOSITORY}pitch-crc:${PITCH_VERSION} -l $(sed -n 2p LicenseFile.txt)

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
 xserver:
  image: ${REPOSITORY}xserver
  ports:
  - "8080:8080"
 
 crc:
  image: ${REPOSITORY}pitch-crc:${PITCH_VERSION}L
  mac_address: ${MAC_ADDRESS}
  environment:
  - DISPLAY=${DISPLAY}
  ports:
  - "8989:8989"
```

Start the composition with ``docker-compose up`` and verify in the Pitch CRC UI that the correct number of licenses is set.

