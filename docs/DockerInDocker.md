# Running the CRC with Docker In Docker

**Caveat: this is experimental.**

To work around the user defined MAC address restriction we will use Docker in Docker (DiD). The CRC image is turned into a volume that is mounted into the DiD container, but appears as a normal container to the  docker daemon running inside the DiD container. Here the container is attached to a Docker bridge network that supports user defined MAC addresses.

The steps to do this are shown below. Variations may be applied, such as injecting the license key into the CRC image, before turning it into a volume. The DiD setup can subsequently be used in Kubernetes.

Note that the preferred alternative is to use a license server.

## Prepare a DinD image with the CRC

Create and change into the directory ``dind``
````
mkdir $HOME/dind
cd $HOME/dind
````

Create the following `.env` file (adapt values such as the MAC address and X Display as needed):

````
REPOSITORY=
PITCH_CRC_VERSION=5.5.0.0L
MAC_ADDRESS=00:18:8B:0D:4F:0B
DISPLAY=192.168.137.11:0
````

Start a DinD container and load a CRC container into the DinD. The container data is saved to `$HOME/dind/var/lib/docker`.

````
# source the environment variables
source .env

# start a DiD container and mount /var/lib/docker
docker run --rm --privileged --name dind -p 22375:2375 -v $HOME/dind/var/lib/docker:/var/lib/docker -d docker:dind dockerd -H tcp://0.0.0.0:2375

# load the CRC container into DiD so that data appears in /var/lib/docker
docker save ${REPOSITORY}pitch/crc:${PITCH_CRC_VERSION} | docker -H :22375 load

# Stop DiD
docker stop dind
````

## Create data image with the CRC

At this point the CRC image shows as data under the locally mounted `var/lib/docker` directory. There are a few steps to perform to create a volume from this data.

Change ownership of the ``var`` directory:

````
sudo chown -R $USER:$USER var
````

Remove any ``whiteout`` files since these cannot be copied and cause an error in the build. A whiteout file is an empty file with a special filename that signifies a path should be deleted. Whiteout files start with ``.wh.``.

````
find -name \.wh.'*' -delete
````

Also remove bock and character special files because these will cause a problem in building the image. Removal of these files seems unharmful.

````
find . -type c -delete
find . -type b -delete
````

Create the following `Dockerfile`:

````
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
````

The entrypoint is defined such that the contents of ``/var/lib/docker`` can optionally be copied to another directory upon start of this container. This feature is used when running this container under Kubernetes.

Create the following docker compose file:

````
version: '3'

services:
 image:
  build:
   context: .
   args:
    SRC: var/lib/docker
    VOLUMEDIR: /var/lib/docker
   dockerfile: Dockerfile
  image: ${REPOSITORY}pitch/crc-volume:${PITCH_CRC_VERSION}
````

Build the crc volume. When we run `docker-compose build`,  Docker compose creates a tar ball of the build context to be sent to the engine. It does that in a temporary file. If  `/tmp` is too small we run out of disk space. If that is the case use another TMPDIR such as below:

````
TMPDIR=$(pwd) docker-compose build
````

## Run DiD with the CRC

Start data container. This will copy the CRC volume to the host file system:

````
docker run --name crc-volume ${REPOSITORY}pitch/crc-volume:${PITCH_CRC_VERSION}
````

Start the DiD with the CRC volume:

````
docker run --rm --privileged \
	-p 22375:2375 -p 8989:8989 \
	--volumes-from crc-volume --name dind -d docker:dind dockerd -H tcp://0.0.0.0:2375
````

Test if the crc container image is present:

````
docker -H :22375 images
````

Start the CRC container within the DiD:

````
docker -H :22375 run -d --restart=always \
	-p 8989:8989 \
	-e DISPLAY=${DISPLAY} \
	--mac-address=${MAC_ADDRESS} \
	--name crc ${REPOSITORY}pitch/crc:${PITCH_CRC_VERSION}
````

Test if the CRC container is running:

````
docker -H :22375 ps
````

Stop and remove the containers:

````
docker stop did crc-volume
docker rm did crc-volume
````
And, finally, prune the CRC volume:

````
docker volume prune -f
````

