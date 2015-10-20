#!/bin/bash
#
# Script to call VirtualBox VM's active IP address
# If no interface is specified script will use interface 0
#
# Usage: getvbip [-i interface_number] virtualbox_vm_name
#
# Returns: 32 bit IPv4 address
#
# Exit Codes:
#     0 - Script appeared to complete successfully
#     1 - Improper usage

EXITVAL=0
VMINT=0
VMIP=
VMNAME=

# Returns script usage info and exits
return_usage () {
    echo "Usage: $0 [-i interface_number] virtualbox_vm_name"
    EXITVAL=1
    exit $EXITVAL
}

# Check if interface value is integer, otherwise exit
# Usage: check_int somevalue
check_int () {
    if ! [ "$1" -eq "$1" ] 2> /dev/null
    then
        echo "Interface option only accepts integers!"
        return_usage
    fi
}

# Option handling
case "$1" in
    "")
        return_usage
        ;;
    -i)
        case "$2" in
            "")
                return_usage
                ;;
            *)
                check_int $2
                VMINT=$2
                case "$3" in
                    "")
                        return_usage
                        ;;
                    *)
                        VMNAME=$3
                        ;;
                esac
                ;;
        esac
        ;;
    *)
        VMNAME=$1
        ;;
esac

# TODO: Check if VM exists
# TODO: Check if VM is powered on
# TODO: Check if interface exists

VMIP=$(VBoxManage guestproperty enumerate $VMNAME | grep "Net/$VMINT/V4/IP" | cut -d',' -f 2 | cut -d' ' -f 3)

echo "$VMIP"
           
exit $EXITVAL 
