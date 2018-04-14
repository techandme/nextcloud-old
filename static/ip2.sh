#!/bin/bash

# Tech and Me © - 2018, https://www.techandme.se/

# shellcheck disable=2034,2059
true
# shellcheck source=lib.sh
. <(curl -sL https://raw.githubusercontent.com/nextcloud/vm/master/lib.sh)

# Check for errors + debug code and abort if something isn't right
# 1 = ON
# 0 = OFF
DEBUG=0
debug_mode

# Copy old interfaces file
msg_box "Copying old interfaces file to:

/tmp/interfaces.backup2"
check_command cp -v /etc/network/interfaces /tmp/interfaces.backup2

# Check if this is VMware:
install_if_not virt-what
if [ "$(virt-what)" == "vmware" ]
then
cat <<-IPCONFIG > "$INTERFACES"
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo $IFACE2
iface lo inet loopback

# The primary network interface
iface $IFACE2 inet static
pre-up /sbin/ethtool -K $IFACE2 tso off
pre-up /sbin/ethtool -K $IFACE2 gso off
# Fixes https://github.com/nextcloud/vm/issues/92:
pre-up ip link set dev $IFACE2 mtu 1430

# Best practice is to change the static address
# to something outside your DHCP range.
address $ADDRESS
netmask $NETMASK
gateway $GATEWAY

# This is an autoconfigured IPv6 interface
# iface $IFACE2 inet6 auto

# Exit and save:	[CTRL+X] + [Y] + [ENTER]
# Exit without saving:	[CTRL+X]

IPCONFIG
else
cat <<-IPCONFIGnonvmware > "$INTERFACES"
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo $IFACE2
iface lo inet loopback

# The primary network interface
iface $IFACE2 inet static
# Fixes https://github.com/nextcloud/vm/issues/92:
pre-up ip link set dev $IFACE2 mtu 1430

# Best practice is to change the static address
# to something outside your DHCP range.
address $ADDRESS
netmask $NETMASK
gateway $GATEWAY

# This is an autoconfigured IPv6 interface
# iface $IFACE2 inet6 auto

# Exit and save:	[CTRL+X] + [Y] + [ENTER]
# Exit without saving:	[CTRL+X]

IPCONFIGnonvmware
fi

exit 0