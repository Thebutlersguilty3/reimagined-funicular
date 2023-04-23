#!/bin/bash

. ./VARIABLES.sh

echo "Copying build.prop for each image"
cp "$PropRoot/build_system_ext.prop" /mnt/system_ext/build.prop
cp "$PropRoot/build_system.prop" /mnt/system/build.prop
cp "$PropRoot/build_system.prop" /mnt/system/system/build.prop
cp "$PropRoot/build_product.prop" /mnt/product/build.prop
cp "$PropRoot/build_vendor.prop" /mnt/vendor/build.prop
cp "$PropRoot/build_vendor_odm.prop" /mnt/vendor/odm/etc/vendor.prop

printf 'removing duplicate apps from system\n'
rm -Rf $InstallDir/priv-app/PackageInstaller/

echo "Copying GApps files to system..."
cp -f -a $GAppsOutputFolder/app/* $InstallDir/app
cp -f -a $GAppsOutputFolder/etc/* $InstallDir/etc
cp -f -a $GAppsOutputFolder/priv-app/* $InstallDir/priv-app
cp -f -a $GAppsOutputFolder/framework/* $InstallDir/framework
cp -fra  $GAppsRoot/product_output/* $MountPointProduct/

echo "Applying root file ownership"
find $InstallDir/app -exec chown root:root {} &>/dev/null \;
find $InstallDir/etc -exec chown root:root {} &>/dev/null \;
find $InstallDir/priv-app -exec chown root:root {} &>/dev/null \;
find $InstallDir/framework -exec chown root:root {} &>/dev/null \;
find $InstallDir/lib -exec chown root:root {} &>/dev/null \;
find $InstallDir/lib64 -exec chown root:root {} &>/dev/null \;
find $MountPointProduct/overlay -exec chown root:root {} &>/dev/null \;

echo "Setting directory permissions"
find $InstallDir/app -type d -exec chmod 755 {} \;
find $InstallDir/etc -type d -exec chmod 755 {} \;
find $InstallDir/priv-app -type d -exec chmod 755 {} \;
find $InstallDir/framework -type d -exec chmod 755 {} \;
find $InstallDir/lib -type d -exec chmod 755 {} \;
find $InstallDir/lib64 -type d -exec chmod 755 {} \;
find $MountPointProduct/overlay -type d -exec chmod 755 {} \;

echo "Setting file permissions"
find $InstallDir/app -type f -exec chmod 644 {} \;
find $InstallDir/priv-app -type f -exec chmod 644 {} \;
find $InstallDir/framework -type f -exec chmod 644 {} \;
find $InstallDir/lib -type f -exec chmod 644 {} \;
find $InstallDir/lib64 -type f -exec chmod 644 {} \;
find $InstallDir/etc/permissions -type f -exec chmod 644 {} \;
find $InstallDir/etc/default-permissions -type f -exec chmod 644 {} \;
find $InstallDir/etc/preferred-apps -type f -exec chmod 644 {} \;
find $InstallDir/etc/sysconfig -type f -exec chmod 644 {} \;
find $MountPointProduct/overlay -type f -exec chmod 644 {} \;

echo "Applying SELinux security contexts to directories"
find $InstallDir/app -type d -exec chcon --reference=$InstallDir/app {} \;
find $InstallDir/priv-app -type d -exec chcon --reference=$InstallDir/priv-app {} \;
find $InstallDir/framework -type d -exec chcon --reference=$InstallDir/framework {} \;
find $InstallDir/lib -type d -exec chcon --reference=$InstallDir/lib {} \;
find $InstallDir/lib64 -type d -exec chcon --reference=$InstallDir/lib64 {} \;
find $InstallDir/etc/permissions -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/default-permissions -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/preferred-apps -type d -exec chcon --reference=$InstallDir/etc/permissions {} \;
find $InstallDir/etc/sysconfig -type d -exec chcon --reference=$InstallDir/etc/sysconfig {} \;
find $MountPointProduct/overlay -type d -exec chcon --reference=$MountPointVendor/overlay {} \;

echo "Applying SELinux security contexts to files"
find $InstallDir/framework -type f -exec chcon --reference=$InstallDir/framework/ext.jar {} \;
find $InstallDir/app -type f -exec chcon --reference=$InstallDir/app/CertInstaller/CertInstaller.apk {} \;
find $InstallDir/priv-app -type f -exec chcon --reference=$InstallDir/priv-app/Shell/Shell.apk {} \;
find $InstallDir/lib -type f -exec chcon --reference=$InstallDir/lib/libcap.so {} \;
find $InstallDir/lib64 -type f -exec chcon --reference=$InstallDir/lib64/libcap.so {} \;
find $InstallDir/etc/permissions -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/default-permissions -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/preferred-apps -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $InstallDir/etc/sysconfig -type f -exec chcon --reference=$InstallDir/etc/fs_config_dirs {} \;
find $MountPointProduct/overlay -type f -exec chcon --reference=$MountPointVendor/overlay/framework-res__auto_generated_rro_vendor.apk {} \;

echo "Applying SELinux policy"
# Sed will remove the SELinux policy for plat_sepolicy.cil, preserve policy using cp
cp $InstallDir/etc/selinux/plat_sepolicy.cil $InstallDir/etc/selinux/plat_sepolicy_new.cil
sed -i 's/(allow gmscore_app self (process (ptrace)))/(allow gmscore_app self (process (ptrace)))\n(allow gmscore_app self (vsock_socket (read write create connect)))\n(allow gmscore_app device_config_runtime_native_boot_prop (file (read)))/g' $InstallDir/etc/selinux/plat_sepolicy_new.cil
cp $InstallDir/etc/selinux/plat_sepolicy_new.cil $InstallDir/etc/selinux/plat_sepolicy.cil
rm $InstallDir/etc/selinux/plat_sepolicy_new.cil

# Prevent android from using cached SELinux policy
echo '0000000000000000000000000000000000000000000000000000000000000000' > $InstallDir/etc/selinux/plat_sepolicy_and_mapping.sha256

echo "!! Apply completed !!"
