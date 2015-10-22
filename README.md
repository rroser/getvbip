# getvbip
Short script to call the interface IP address of a running VirtualBox VM

This script is intended as a way to help easily and quickly connect to services
running on local VirtualBox VMs that have changing IP addresses or multiple
network interfaces. It is meant to allow you to store simple links and profiles
for easy access without having to manually lookup the interface IP address each
time the service is accessed.

Examples:

    Ping
    ping `getvbip VM_Name`

    SSH
    ssh user@`getvbip VM_Name`

    RDP RemoteApp
    xfreerdp --app --plugin rails --data "||shared_program" -- `getvbip VM_Name`

Usage:

    Usage: getvbip [-i interface_number] virtualbox_vm_name

TODO:

    Select interface based on what networks are active on the Host OS

    Create install script to add to system binary directory
