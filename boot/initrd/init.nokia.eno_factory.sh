#!/system/bin/sh
# Copyright (c) 2009-2013, Nokia. All rights reserved.
#
# Actions on fast factory test mode

    #Create QMUX deamon socket area
    mkdir -p /dev/socket/qmux_radio
    chown -h radio.radio /dev/socket/qmux_radio
    chmod -h 2770 /dev/socket/qmux_radio
    mkdir -p /dev/socket/qmux_audio
    chown -h media.audio /dev/socket/qmux_audio
    chmod -h 2770 /dev/socket/qmux_audio
    mkdir -p /dev/socket/qmux_bluetooth
    chown -h bluetooth.bluetooth /dev/socket/qmux_bluetooth
    chmod -h 2770 /dev/socket/qmux_bluetooth
    mkdir -p /dev/socket/qmux_gps
    chown -h gps.gps /dev/socket/qmux_gps
    chmod -h 2770 /dev/socket/qmux_gps

    # Allow QMUX daemon to assign port open wait time
    chown -h radio.radio /sys/devices/virtual/hsicctl/hsicctl0/modem_wait

    # Permissions for System Server and daemons.
    chown -h system.system /sys/power/autosleep
    chown -h system.system /sys/power/state
    chown -h system.system /sys/power/wakeup_count
    chown -h radio.system /sys/power/wake_lock
    chown -h radio.system /sys/power/wake_unlock
    chmod -h 0660 /sys/power/state
    chmod -h 0660 /sys/power/wake_lock
    chmod -h 0660 /sys/power/wake_unlock

    netcfg lo up
    netcfg upnlink0 up
    start config_bluetooth
    start qcom-c_main-sh
    start qcom-usb-sh
    setprop persist.sys.usb.config winusb_phonet,diag,adb
    start testserver
    start infoserver
    start qcom-post-boot
    touch /mnt/shell/emulated/0
