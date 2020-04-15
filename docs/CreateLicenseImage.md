# Create a Pitch RTI license container

The Pitch RTI requires a license key in order to run. The license file with the license key and the associated MAC address must be requested from the vendor.

The steps below describe how to create a license container image and how to run the Pitch CRC with the license container. The creation of the license container image has to be done only once. Note that these steps are only valid for the "non-free" Pitch RTI. The free Pitch RTI does not have a license activator.

Run the following steps on your Docker host for the volume mounts to work correctly.

## Create build directory and environment settings file

Prepare a `builddir` with a `.env` file in it:

````Ada
mkdir builddir

cd builddir

# Change the following environment values to match your license key:
cat << EOF >> .env
REPOSITORY=hlacontainers/
PITCH_VERSION=5_5_0_0
LICENSE_IMAGE=pitch-crc-license
MAC_ADDRESS=00:18:8B:0D:4F:0B
DISPLAY=xserver:0
EOF
````

The value for the MAC address above is an example. Adapt the value of `MAC_ADDRESS` to a value that matches with the license key. Optionally set the value of `DISPLAY` to an X Display. This setting is used later to run the Pitch CRC container with an X Display.

## Run license activator

Copy the license file to the build directory and rename the file to `LicenseFile.txt`.

Next, run the license activator to create the file `prefs.xml`, using the following command from a Linux shell:

```
source .env

docker run \
  --mac-address=${MAC_ADDRESS} \
  --rm -v $PWD:/etc/.java/.systemPrefs/se/pitch/prti1516e/config \
  ${REPOSITORY}pitch-crc:${PITCH_VERSION} -l $(sed -n 2p LicenseFile.txt)
```

After running this command a file `prefs.xml` should be created in the current working directory.

## Create license container image

In this step a license container image is built with the license key file in it. We use `docker-compose` to create the license container image.

Create the following two files in the `builddir`:

The file `docker-compose.yml`:

```
version: '3'

services:
 license:
  build:
   context: .
   args:
    SRC: prefs.xml
    VOLUMEDIR: /data
   dockerfile: Dockerfile
  image: ${LICENSE_IMAGE}
```

And the file `Dockerfile`:

```
FROM busybox
ENTRYPOINT [ "sh", "-c", " \
   if [ -n \"$VOLUME\" -a -n \"$1\" ]; then \
      if [ -n \"$OPTS\" ]; then \
         cp $OPTS $VOLUME $1; \
      else \
         cp -a $VOLUME $1; \
      fi; \
      echo \"Copied $VOLUME to $1\"; \
   fi" , \
"--" ]

ARG SRC
ARG VOLUMEDIR
ENV VOLUME ${VOLUMEDIR}/.
COPY ${SRC} ${VOLUMEDIR}/
VOLUME ${VOLUMEDIR}
```

The script defined for `ENTRYPOINT` is used to optionally initialize a volume with the data from the license container. When the container is run with an argument, the data in the container is copied by the script to the provided directory location. Docker does this automatically by declaring a `VOLUME` and there is no need for such a script, however under Kubernetes this must be done explicitly through the entry point script.

And lastly build the license container image with the following command:

````
docker-compose build
````

## Run the Pitch CRC with a license container

In this final step we show how to run the Pitch CRC with a license container. Again, we use `docker-compose` to start the containers.

First create the directory `rundir` and copy the previously created `.env` file from the `builddir` to the `rundir`. Change to the `rundir`.

Next, create the following ``docker-compose.yml`` file:

```
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
  volumes:
  - license_volume:/etc/.java/.systemPrefs/se/pitch/prti1516e/config:nocopy
  depends_on:
  - license

 license:
  image: ${LICENSE_IMAGE}
  volumes:
  - license_volume:/data

volumes:
 license_volume:
```

Start the composition with ``docker-compose up``.

Note that once the composition is started the license container exits with zero status. This is correct. The data from the license container image has been copied to the host filesystem as a volume, from where it is mounted by the crc container.

If a value for `DISPLAY` has been provided, check the Pitch CRC UI if the correct number of licenses is shown.

## Update the license key

In case the license container is updated with new license data, the license volume needs to be removed from the host filesystem so that the new data can be copied to the host filesystem. To remove the license volume from the host filesystem, make sure that no container that mounts the volume exists (either running or stopped). You can verify this with the command `docker ps -a`. If no container mounts the data volume anymore, then use the command `docker volume prune` to remove the license volume.

## Use convenience script for building license container image

Once the `builddir` with the content described in the steps above is in place, the creation of the license container image can be automated by running the script `build.sh` located in the repository `builddir`.

