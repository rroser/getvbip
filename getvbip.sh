#!/bin/bash
#
# Script to call VirtualBox VM's active IP address
# If no interface is specified script will use interface 0
#
# Usage: getvbip [-i interface_number] virtualbox_vm_name
#
# Output: 32 bit IPv4 address
#
# Exit Codes:
#     0 - Script appeared to complete successfully
#     1 - Improper usage
#     2 - Specified VM doesn't exist
#     3 - VM isn't powered on
#     4 - No active interfaces on VM

EXITVAL=0
VMINT=0
VMIP=
VMNAME=

# Returns script usage info and exits
output_usage () {
    echo "Usage: $0 [-i interface_number] virtualbox_vm_name" 1>&2
    EXITVAL=1
    exit $EXITVAL
}

# Check if interface value is integer, otherwise exit
# Usage: check_int somevalue
check_integer () {
    if ! [ "$1" -eq "$1" ] 2> /dev/null
    then
        echo "Interface option only accepts integers!" 1>&2
        output_usage
    fi
}

# Option handling
case "$1" in
    "")
        output_usage
        ;;
    -i)
        case "$2" in
            "")
                output_usage
                ;;
            *)
                check_integer $2
                VMINT=$2
                case "$3" in
                    "")
                        output_usage
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

# Check if VM exists
check_vm_exists () {
    EXITVAL=2
    vbmout=$(VBoxManage list vms)
    while read line
    do
        vm=$(echo $line | cut -d' ' -f 1 | cut -d'"' -f 2)
        if [ "$1" = "$vm" ];
        then
            EXITVAL=0
        fi
    done <<<"$vbmout"
    if [ $EXITVAL -eq 2 ];
    then
        echo "Specified VM does not exist!" 1>&2
        exit $EXITVAL
    fi
}

# Check if VM is powered on
check_power () {
    EXITVAL=3
    vbmout=$(VBoxManage list runningvms)
    while read line
    do
        vm=$(echo $line | cut -d' ' -f 1 | cut -d'"' -f 2)
        if [ "$1" = "$vm" ];
        then
            EXITVAL=0
        fi
    done <<<"$vbmout"
    if [ $EXITVAL -eq 3 ];
    then
        echo "Specified VM is not currently running!" 1>&2
        exit $EXITVAL
    fi
}

# Check if interface exists and is up
check_interface () {
    vbmout=$(VBoxManage guestproperty enumerate $VMNAME | grep "/Net/$1/Status")
    if [ -z "$vbmout" ];
    then
        echo "Interface does not exists!" 1>&2
        EXITVAL=4
        exit $EXITVAL
    else
        intstat=$(echo $vbmout | cut -d',' -f 2 | cut -d' ' -f 3)
        if ! [ "$intstat" = "Up" ];
        then
            echo "Interface is down!" 1>&2
            EXITVAL=4
            exit $EXITVAL
        fi
    fi
}

check_vm_exists $VMNAME
check_power $VMNAME
check_interface $VMINT
VMIP=$(VBoxManage guestproperty get $VMNAME "/VirtualBox/GuestInfo/Net/$VMINT/V4/IP" | cut -d' ' -f 2)

echo "$VMIP"
           
exit $EXITVAL 
