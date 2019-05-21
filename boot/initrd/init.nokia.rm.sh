#!/system/bin/sh
# Copyright (C) 2014 Nokia Corporation and/or its subsidiary(-ies). All rights reserved.
#
# This material, including documentation and any related computer programs,
# is protected by copyright controlled by Nokia. All rights are reserved.
# Copying, including reproducing, storing, adapting or translating,
# any or all of this material requires the prior written consent of Nokia.
# This material also contains confidential information, which may not be disclosed
# to others without the prior written consent of Nokia.
#

bom=`getprop ro.boot.bom`

case "$bom" in
	rel2.qb.ss)
		setprop ro.product.name "RM-1059"
		setprop ro.product.model "genm15"
		setprop ro.product.usb.name "genm15 (RM-1059)"
		echo "genm15 (RM-1059)" > /sys/class/android_usb/android0/iProduct
		;;
	rel2.qb.ds)
		setprop ro.product.name "RM-1057"
		setprop ro.product.model "genm14"
		setprop ro.product.usb.name "genm14 (RM-1057)"
		echo "genm14 (RM-1057)" > /sys/class/android_usb/android0/iProduct
		;;
esac
