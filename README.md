![Build Status](https://img.shields.io/docker/cloud/build/hlacontainers/pitch-crc)
![Pulls](https://img.shields.io/docker/pulls/hlacontainers/pitch-crc)

# Pitch CRC image
The Pitch Central RTI Component (CRC) is an application that manages one or more federation executions within the Pitch RTI. For example, it keeps track of joined federates and maintains information about the publication and subscription interests of individual federates. The CRC is a required application when using the Pitch RTI.

This repository contains the files and instructions to build and run a Docker container image for the Pitch CRC. **This repository does not include any Pitch files**. The Pitch RTI and license keys must be acquired from the vendor. A free version of the Pitch RTI for two federates can be requested from the vendor site. For more information about the Pitch RTI, see http://pitchtechnologies.com. 

By default a **skeleton** Docker container image is built from the files in this repository. A skeleton container image does not include any Pitch proprietary files. These files must be mounted into the CRC container at run-time in order to create a functional CRC container.

For the instructions to build a skeleton or a complete Pitch CRC container image see [BUILDME](BUILDME.md).

The simplest way to start the Pitch CRC container is with the following `docker-compose.yml` file, where in this example:

- The Pitch CRC container image is a skeleton image. 
- The **Linux edition** of the Pitch Free RTI is installed on the host file system under the directory `${PITCH_RTI_HOME}`.

````
version: '3'

services:
 xserver:
  image: ${REPOSITORY}xserver
  ports:
  - "8080:8080"
 
 crc:
  image: ${REPOSITORY}pitch-crc:${PITCH_VERSION}
  volumes:
  - ${PITCH_RTI_HOME}:/usr/local/prti1516e
  environment:
  - DISPLAY=${DISPLAY}
  ports:
  - "8989:8989"
````

And where the following `.env` file is used:

````
# Repository prefix
REPOSITORY=hlacontainers/

# Pitch version
PITCH_VERSION=skeleton

# X DISPLAY for the CRC (required for the Pitch Free RTI, optional for a licensed RTI)
DISPLAY=xserver:0

# Host installation directory of the Pitch RTI (TAILOR THIS TO YOUR OWN ENVIRONMENT)
# For example:
# - on Linux: PITCH_RTI_HOME=/usr/local/prti1516e
# - on Windows: PITCH_RTI_HOME=C:\Program Files\prti1516e
PITCH_RTI_HOME=/usr/local/prti1516e
````

The environment file should be used to tailor the composition to the local infrastructure, such as the address of the X Server or the installation directory of the Pitch RTI.

Port 8989 is the default port on which the Pitch CRC listens for connection requests from a Local RTI Component (LRC).

The Pitch Free RTI requires an X Display for displaying a message about the End User License Agreement.  The user must accept this agreement, after which the CRC listen port is opened. For the licensed RTI the X Display is optional.

## Container synopsis

````
pitch-crc:<version> [-m <mac address>] [-l <license key>] [-i] [-x]
````

`-m` : Create a network interface with the provided MAC address. This option should be used to set a MAC address license. Requires container `NET_ADMIN` capability. Supersedes `CRC_MACADDRESS`setting.

`-l` : Run license activator with the given license key. This option should be used when to set a MAC address license. Supersedes `CRC_LICENSE` setting.

`-i` : Set interactive mode. This option should be used in combination with the docker option `-i` in order to use the container TTY. Default is non-interactive. Supersedes `CRC_INTERACTIVE` setting.

`-x` : Exit after initialization, but before starting the CRC.  Supersedes `CRC_EXIT` setting.

Ports:

`8989` : CRC listen port for Local RTI Components. See environment variable `CRC_LISTENPORT`.

`1099` : RMI Registry listen port for Pitch Web UI.

## Environment variables

The Pitch CRC has many configuration settings, stored in the file `prti1516eCRC.settings`.  A small subset of these can be changed via environment variables. These are listed in the table below and for the details we refer to the Pitch user documentation.

| Environment variable               | Default                    | Description                                                  | Required |
| ---------------------------------- | -------------------------- | ------------------------------------------------------------ | -------- |
| ``CRC_NICKNAME``                   | `crc-<container hostname>` | The nickname for the CRC. The setting is relevant in **Booster Mode**, where the value is used to identify the CRC in the booster network. | No       |
| ``CRC_LISTENPORT``                 | ``8989``                   | CRC listen port number.                                      | No       |
| ``CRC_CONNECTIVITY_CHECK``         | -                          | When set to a non-empty string, a connectivity test to a connecting LRC is performed. | No       |
| ``CRC_REJECT_MISMATCHED_VERSIONS`` | -                          | When set to a non-empty string, a miss-matching LRC version is rejected. | No       |
| ``CRC_BOOSTERADDRESS``             | -                          | The address of the booster to connect to. The format of the address is `<BoosterHost>:<BoosterPort>`. If set, the CRC is started in **Booster Mode**, using the given booster address. If not set, the CRC starts in **Direct Mode**. | No       |
| `CRC_BOOSTER_ADVERTISE_ADDRESS`    | -                          | Advertised address of the CRC to Booster. Format is `<Host>[:<Port>]`. This setting is only applicable in **Booster Mode**. See Pitch Manual for more information. | No       |
| ``CRC_LICENSE_SERVER_HOST``        | -                          | The address of the license server host to connect to for LRC licenses. The host is either a hostname or an IP address. | No       |
| ``CRC_LICENSE_SERVER_COUNT``       | -                          | The number of licenses to check out from the license server. | No       |
| ``DISPLAY``                        | -                          | If set, use this X display as GUI. If no display is specified then the CRC will not attempt to connect to the X Server. The X display format is: ``<X Server host>``:``<Display number>``.  For the display number the value ``0`` is typically used. | No       |
| `CRC_MACADDRESS`                   | -                          | MAC address related to license key. Requires that container has `NET_ADMIN` capability. | No       |
| `CRC_LICENSE`                      | -                          | License key related to MAC address.                          | No       |
| `CRC_INTERACTIVE`                  | -                          | Start CRC in interactive mode. Requires that container runs in interactive mode too. | No       |
| `CRC_EXIT`                         | -                          | Exit once initialization has completed.                      | No       |

If `CRC_BOOSTERADDRESS` is set then the Pitch CRC container will wait for the Pitch Booster listen port to open before starting the CRC application. Similarly, if `DISPLAY` is set then the Pitch CRC container will wait for the X Server listen port to open before starting the CRC application.

## Run the Pitch CRC with a license

There are two ways to run the Pitch CRC container with a license:

- Use a license server. This is by far the easiest option. The address of the license server and the number of required licenses can be set via the available environment variables.
- Use a MAC address based license. This requires that the container is started with a specific MAC address associated with the license key.

With the MAC address based license the CRC container must have a network interface whose MAC address is associated with the license key. This can be achieved in two ways:

- start the container with the docker option `--mac-address`;
- start the container with either the command line option `-m` or with the environment variable `CRC_MACADDRESS`. This option requires that the container has the `NET_ADMIN` capability set.

There are several ways to provide the license key to the CRC container, explained next.

### Provide license every time the container is started

The license can be provided to the container with either the command line option `-l`, or with the environment variable `CRC_LICENSE`.

### Mount license key

The license key can be mounted from the host file system or from a license container. The latter option provides more flexibility in running the CRC since the license container can be deployed together with the CRC without having to worry about host filesystem mounts. Several (one-off) steps need to be performed to create a license container image. The details can be found at [Create a Pitch License Container](docs/CreateLicenseImage.md).

### Inject license key

The license key can also be injected in the CRC container image, making it a permanent part of the CRC image. The details can be found at [Inject a License into the Pitch CRC image](docs/InjectLicense.md).

With this option a new (licensed) CRC image is created. As a best practice the letter `L` is added to the version to indicate that the image holds a license key, for example:

````
hlacontainers/pitch-crc:5_5_0_0L
````

## Provide an alternate Pitch RID file

The environment variables listed above are for a small number of Pitch CRC settings. To change the entire RID file, just mount an alternate, but identically named settings file at ``/root/prti1516e/prti1516eCRC.settings``.

