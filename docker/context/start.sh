#!/bin/sh

#
# Copyright 2020 Tom van den Berg (TNO, The Netherlands).
# SPDX-License-Identifier: Apache-2.0
#

# Start script for CRC

WaitForHostPort() {
	_NAME=$1
	_HOST=$2
	_PORT=$3

	down=1
	while [ $down -ne 0 ]; do
		echo "CRC: Wait for $_NAME at $_HOST:$_PORT"

		# Check if the port is open; use the -z option to just scan and not connect
		down=`nc -z $_HOST $_PORT < /dev/null > /dev/null; echo $?`

		# Sleep for the next attempt
		sleep 1
	done
	echo "CRC: $_NAME $_HOST:$_PORT is up"
}

WaitForXServer() {
	#split address
	_OLDIFS=$IFS
	IFS=:
	set -- $1
	XHOST=$1
	XDISPLAY_SCREEN=$2
	IFS=.
	set -- $XDISPLAY_SCREEN
	XDISPLAY=$1
	XSCREEN=$2
	IFS=$_OLDIFS

	if [ "$XHOST" = "" ]; then
		echo "CRC: no host or display set in '$DISPLAY' (ignored)"
		return
	fi
	
	if [ "$XDISPLAY" = "" ]; then
		echo "CRC: DISPLAY number is not set, assume 0"
		XDISPLAY=0
	fi
	
	#Update display
	DISPLAY=${XHOST}:${XDISPLAY}

	XPORT=`expr $XDISPLAY + 6000`
		
	WaitForHostPort "XServer" $XHOST $XPORT
}

WaitForBooster() {	
	#split address
	_OLDIFS=$IFS
	IFS=:
	set -- $1
	XHOST=$1
	XPORT=$2
	IFS=$_OLDIFS

	WaitForHostPort "Booster" $XHOST $XPORT
}

# Set defaults
X=${CRC_NICKNAME:=crc-`hostname`}
X=${CRC_LISTENPORT:=8989}
X=${CRC_SKIP_CONNECTIVITY_CHECK:=1}
X=${CRC_REJECT_MISMATCHED_VERSIONS:=0}
X=${CRC_LICENSE_SERVER_COUNT:=0}

if [ "$CRC_SKIP_CONNECTIVITY_CHECK" = "0" ]; then
	CRC_SKIP_CONNECTIVITY_CHECK="0"
else
	CRC_SKIP_CONNECTIVITY_CHECK="1"
fi

if [ "$CRC_REJECT_MISMATCHED_VERSIONS" = "0" ]; then
	CRC_REJECT_MISMATCHED_VERSIONS="0"
else
	CRC_REJECT_MISMATCHED_VERSIONS="1"
fi

echo "CRC: CRC_NICKNAME="$CRC_NICKNAME
echo "CRC: CRC_LISTENPORT="$CRC_LISTENPORT
echo "CRC: CRC_SKIP_CONNECTIVITY_CHECK="$CRC_SKIP_CONNECTIVITY_CHECK
echo "CRC: CRC_REJECT_MISMATCHED_VERSIONS="$CRC_REJECT_MISMATCHED_VERSIONS
echo "CRC: CRC_BOOSTERADDRESS="$CRC_BOOSTERADDRESS
echo "CRC: CRC_BOOSTER_ADVERTISE_ADDRESS="$CRC_BOOSTER_ADVERTISE_ADDRESS
echo "CRC: CRC_LICENSE_SERVER_HOST="$CRC_LICENSE_SERVER_HOST
echo "CRC: CRC_LICENSE_SERVER_COUNT="$CRC_LICENSE_SERVER_COUNT
echo "CRC: DISPLAY="$DISPLAY

interactive="0"
license=""

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "l:i" opt; do
    case "$opt" in
	l)	license=$OPTARG
        ;;
	i)	interactive="1"
		;;
	esac
done

# shift away processed options
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ "$license" != "" ]; then
	echo "CRC: run license activator with '$license'"
	${RTI_HOME}/bin/LicenseActivator primary $license
	exit
fi

if [ ! -f "$HOME/prti1516e/prti1516eCRC.settings" ]; then
	# try other location
	if [ -f "${RTI_HOME}/prti1516eCRC.settings" ]; then
		mkdir -p $HOME/prti1516e
		cp ${RTI_HOME}/prti1516eCRC.settings $HOME/prti1516e
	else 
		echo "CRC: prti1516eCRC.settings not found (continue without)"
	fi
fi

if [ -f "$HOME/prti1516e/prti1516eCRC.settings" ]; then
	# Test if booster mode is used
	if [ "$CRC_BOOSTERADDRESS" != "" ]; then
		oldIFS=$IFS
		IFS=:
		set -- $CRC_BOOSTERADDRESS
		boosterHost=$1
		boosterPort=$2
		IFS=$oldIFS

		# Use default port if not set or empty
		X=${boosterPort:=8688}

		sed -i "s/CRC.network.mode.*/CRC.network.mode=booster/" $HOME/prti1516e/prti1516eCRC.settings
		sed -i "s/CRC.booster.address.*/CRC.booster.address=$boosterHost/" $HOME/prti1516e/prti1516eCRC.settings
		sed -i "s/CRC.booster.port.*/CRC.booster.port=$boosterPort/" $HOME/prti1516e/prti1516eCRC.settings
	
		if [ "$CRC_BOOSTER_ADVERTISE_ADDRESS" != "" ]; then
			# delete lines, if present
			sed -i "/CRC.booster.advertise.mode.*/d" $HOME/prti1516e/prti1516eCRC.settings
			sed -i "/CRC.booster.advertise.address.*/d" $HOME/prti1516e/prti1516eCRC.settings
			sed -i "/CRC.booster.tcp.port-range.start.*/d" $HOME/prti1516e/prti1516eCRC.settings
			sed -i "/CRC.booster.tcp.port-range.end.*/d" $HOME/prti1516e/prti1516eCRC.settings
			# and add
			echo "CRC.booster.advertise.mode=User" >> $HOME/prti1516e/prti1516eCRC.settings
			echo "CRC.booster.advertise.address=$CRC_BOOSTER_ADVERTISE_ADDRESS" >> $HOME/prti1516e/prti1516eCRC.settings
			echo "CRC.booster.tcp.port-range.start=6000" >> $HOME/prti1516e/prti1516eCRC.settings
			echo "CRC.booster.tcp.port-range.end=6999" >> $HOME/prti1516e/prti1516eCRC.settings
		fi
	fi

	# Adapt the CRC settings according to the given parameter settings
	sed -i "s/CRC.nickname.*/CRC.nickname=$CRC_NICKNAME/" $HOME/prti1516e/prti1516eCRC.settings
	sed -i "s/CRC.port.*/CRC.port=$CRC_LISTENPORT/" $HOME/prti1516e/prti1516eCRC.settings

	if [ "$CRC_SKIP_CONNECTIVITY_CHECK" = "1" ]; then
		sed -i "s/CRC.skipConnectivityCheck.*/CRC.skipConnectivityCheck=true/" $HOME/prti1516e/prti1516eCRC.settings
	else
		sed -i "s/CRC.skipConnectivityCheck.*/CRC.skipConnectivityCheck=false/" $HOME/prti1516e/prti1516eCRC.settings
	fi

	if [ "$CRC_REJECT_MISMATCHED_VERSIONS" = "1" ]; then
		sed -i "s/CRC.rejectMismatchedVersions.*/CRC.rejectMismatchedVersions=reject/" $HOME/prti1516e/prti1516eCRC.settings
	else
		sed -i "s/CRC.rejectMismatchedVersions.*/CRC.rejectMismatchedVersions=accept/" $HOME/prti1516e/prti1516eCRC.settings
	fi

	if [ "$CRC_LICENSE_SERVER_HOST" != "" ]; then
		# add new lines about license server
		echo "CRC.licenseType=server" >> $HOME/prti1516e/prti1516eCRC.settings
		echo "CRC.license-server.host=$CRC_LICENSE_SERVER_HOST" >> $HOME/prti1516e/prti1516eCRC.settings
		echo "CRC.license-server.federateCount=$CRC_LICENSE_SERVER_COUNT" >> $HOME/prti1516e/prti1516eCRC.settings
	fi
fi

if [ -n "$DISPLAY" ]; then
	WaitForXServer $DISPLAY
fi

if [ -n "$CRC_BOOSTERADDRESS" ]; then
	WaitForBooster $CRC_BOOSTERADDRESS
fi

echo "CRC: start"

# Start process
cd ${RTI_HOME}/bin

if [ "$interactive" = "1" ]; then
	echo "==============="
	echo "run interactive"
	echo "==============="
	/bin/sh ./prti1516e.sh
else
	echo "==================="
	echo "run non-interactive"
	echo "==================="
	tail -f /dev/null | /bin/sh ./prti1516e.sh
fi
