#!/bin/sh

# Source environment variables
. $PWD/.env

# Get the license key
LICENSE=$(sed -n 2p LicenseFile.txt)

echo "Using:"
echo "PITCH_VERSION"=${PITCH_VERSION}
echo "LICENSE_IMAGE="${LICENSE_IMAGE}
echo "LICENSE="${LICENSE}
echo "MAC_ADDRESS="${MAC_ADDRESS}
echo

rm -f prefs.xml

# Create the license data
docker run \
  --mac-address=${MAC_ADDRESS} \
  --rm -v $PWD:/etc/.java/.systemPrefs/se/pitch/prti1516e/config \
  ${REPOSITORY}pitch-crc:${PITCH_VERSION} -l ${LICENSE}

# And build a license container image with the license key
docker-compose build
