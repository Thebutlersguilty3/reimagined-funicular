#!/bin/bash

. ./VARIABLES.sh

echo "chk product.img"
e2fsck -f $ImagesRoot/product.img

echo "Resizing product.img"
resize2fs $ImagesRoot/product.img 240M

echo "chk system.img"
e2fsck -f $ImagesRoot/system.img

echo "Resizing system.img"
resize2fs $ImagesRoot/system.img 1280M

echo "chk system_ext.img"
e2fsck -f $ImagesRoot/system_ext.img

echo "Resizing system_ext.img"
resize2fs $ImagesRoot/system_ext.img 108M

echo "chk vendor.img"
e2fsck -f $ImagesRoot/vendor.img

echo "Resizing vendor.img"
resize2fs $ImagesRoot/vendor.img 300M

echo "Creating mount point for product"
mkdir -p $MountPointProduct

echo "Creating mount point for system_ext" 
mkdir -p $MountPointSystemExt

echo "Creating mount point for system"
mkdir -p $MountPointSystem

echo "Creating mount point for vendor"
mkdir -p $MountPointVendor

echo "Mounting product"
mount -o rw $ImagesRoot/product.img $MountPointProduct

echo "Mounting system_ext"
mount -o rw $ImagesRoot/system_ext.img $MountPointSystemExt

echo "Mounting system"
mount -o rw $ImagesRoot/system.img $MountPointSystem

echo "Mounting vendor"
mount -o rw $ImagesRoot/vendor.img $MountPointVendor

echo "!! Images mounted !!"