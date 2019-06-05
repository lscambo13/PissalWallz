##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "****************************************************"
  ui_print "     Magisk Pixel Complementary Live Wallpapers     "
  ui_print "                by @igor-dyatlov                    "
  ui_print "****************************************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  ui_print "- Installing  Module"

  DEVICE=`getprop ro.product.device`
  RELEASE=`getprop ro.build.version.release`
  SECURITY_PATCH_VERSION=`getprop ro.build.version.security_patch`

  ui_print " Performing compatibility check"
  ui_print " Device is: "$DEVICE
  ui_print " Android version is: "$RELEASE
  ui_print " Security patch version is: "$SECURITY_PATCH_VERSION

  if [ $DEVICE != "sailfish" ] && [ $DEVICE != "marlin" ] && [ $DEVICE != "walleye" ] && [ $DEVICE != "taimen" ] && [ $DEVICE != "blueline" ] && [ $DEVICE != "crosshatch" ] && [ $DEVICE != "sargo" ] && [ $DEVICE != "bonito" ]; then
    abort "   => Device '"$DEVICE"' is not supported"
  fi
  
  if [ $RELEASE != "9" ]; then
    abort "   => Android version '"$RELEASE"' is not supported"
  fi
  
  if [ $RELEASE == "9" ]; then
    RELEASE=$RELEASE/$SECURITY_PATCH_VERSION
  fi
  ui_print "- Your device is compatible. Continue with installation."
  
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want  
case $DEVICE in
  # "sailfish" for Pixel 9.0.0 (PQ2A.190405.003, Apr 2019)
  sailfish)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/walleye/*' $RELEASE'/blueline/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk.part* > $TMPDIR/$RELEASE/walleye/WallpapersBReel/WallpapersBReel2017.apk
  rm -f $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk.part*
  cat $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk.part* > $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk
  rm -f $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk.part*
  APK_PATH_PX2_W=$TMPDIR/$RELEASE/walleye/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  APK_PATH_PX3_W=$TMPDIR/$RELEASE/blueline/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  LIB_PATH_PX2_D=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/lib/arm64/libgdx.so
  LIB_PATH_PX2_B=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  APK_PATH_PX2_LW=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk
  APK_PATH_PX3_LW=$TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2017
  cp -af $APK_PATH_PX2_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2018
  cp -af $APK_PATH_PX3_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2017/lib/arm64
  cp -af $LIB_PATH_PX2_D $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX2_B $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX2_LW $MODPATH/system/app/WallpapersBReel2017/WallpapersBReel2017.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2018
  cp -af $APK_PATH_PX3_LW $MODPATH/system/app/WallpapersBReel2018/WallpapersBReel2018.apk
  ;;
  # "marlin" for Pixel XL 9.0.0 (PQ2A.190405.003, Apr 2019)
  marlin)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/taimen/*' $RELEASE'/crosshatch/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk.part* > $TMPDIR/$RELEASE/taimen/WallpapersBReel/WallpapersBReel2017.apk
  rm -f $TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk.part*
  cat $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk.part* > $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk
  rm -f $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk.part*
  APK_PATH_PX2_W=$TMPDIR/$RELEASE/taimen/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  APK_PATH_PX3_W=$TMPDIR/$RELEASE/crosshatch/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  LIB_PATH_PX2_D=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/lib/arm64/libgdx.so
  LIB_PATH_PX2_B=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  APK_PATH_PX2_LW=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk
  APK_PATH_PX3_LW=$TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2017
  cp -af $APK_PATH_PX2_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2018
  cp -af $APK_PATH_PX3_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2017/lib/arm64
  cp -af $LIB_PATH_PX2_D $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX2_B $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX2_LW $MODPATH/system/app/WallpapersBReel2017/WallpapersBReel2017.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2018
  cp -af $APK_PATH_PX3_LW $MODPATH/system/app/WallpapersBReel2018/WallpapersBReel2018.apk
  ;;
  # "walleye" for Pixel 2 9.0.0 (PQ2A.190405.003, Apr 2019)
  walleye)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/sailfish/*' $RELEASE'/blueline/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk.part* > $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk
  rm -f $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk.part*
  cat $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk.part* > $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk
  rm -f $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk.part*
  APK_PATH_PX1_W=$TMPDIR/$RELEASE/sailfish/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  APK_PATH_PX3_W=$TMPDIR/$RELEASE/blueline/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  LIB_PATH_PX1_D=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/lib/arm64/libgdx.so
  LIB_PATH_PX1_B=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/lib/arm64/libgeswallpapers-jni.so
  APK_PATH_PX1_LW1=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk
  APK_PATH_PX1_LW2=$TMPDIR/$RELEASE/sailfish/WallpapersUsTwo/WallpapersUsTwo.apk
  APK_PATH_PX3_LW=$TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt
  cp -af $APK_PATH_PX1_W $MODPATH/system/app/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2018
  cp -af $APK_PATH_PX3_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel/lib/arm64
  cp -af $LIB_PATH_PX1_D $MODPATH/system/app/WallpapersBReel/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX1_B $MODPATH/system/app/WallpapersBReel/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX1_LW1 $MODPATH/system/app/WallpapersBReel/WallpapersBReel.apk
  mkdir -p $MODPATH/system/app/WallpapersUsTwo
  cp -af $APK_PATH_PX1_LW2 $MODPATH/system/app/WallpapersUsTwo/WallpapersUsTwo.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2018
  cp -af $APK_PATH_PX3_LW $MODPATH/system/app/WallpapersBReel2018/WallpapersBReel2018.apk
  ;;
  # "taimen" for Pixel 2 XL 9.0.0 (PQ2A.190405.003, Apr 2019)
  taimen)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/marlin/*' $RELEASE'/crosshatch/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk.part* > $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk
  rm -f $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk.part*
  cat $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk.part* > $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk
  rm -f $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk.part*
  APK_PATH_PX1_W=$TMPDIR/$RELEASE/marlin/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  APK_PATH_PX3_W=$TMPDIR/$RELEASE/crosshatch/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  LIB_PATH_PX1_D=$TMPDIR/$RELEASE/marlin/WallpapersBReel/lib/arm64/libgdx.so
  LIB_PATH_PX1_B=$TMPDIR/$RELEASE/marlin/WallpapersBReel/lib/arm64/libgeswallpapers-jni.so
  APK_PATH_PX1_LW1=$TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk
  APK_PATH_PX1_LW2=$TMPDIR/$RELEASE/marlin/WallpapersUsTwo/WallpapersUsTwo.apk
  APK_PATH_PX3_LW=$TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt
  cp -af $APK_PATH_PX1_W $MODPATH/system/app/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2018
  cp -af $APK_PATH_PX3_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel/lib/arm64
  cp -af $LIB_PATH_PX1_D $MODPATH/system/app/WallpapersBReel/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX1_B $MODPATH/system/app/WallpapersBReel/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX1_LW1 $MODPATH/system/app/WallpapersBReel/WallpapersBReel.apk
  mkdir -p $MODPATH/system/app/WallpapersUsTwo
  cp -af $APK_PATH_PX1_LW2 $MODPATH/system/app/WallpapersUsTwo/WallpapersUsTwo.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2018
  cp -af $APK_PATH_PX3_LW $MODPATH/system/app/WallpapersBReel2018/WallpapersBReel2018.apk
  ;;
  # "blueline" for Pixel 3 9.0.0 (PQ2A.190405.003, Apr 2019)
  blueline)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/sailfish/*' $RELEASE'/walleye/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk.part* > $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk
  rm -f $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk.part*
  cat $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk.part* > $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk
  rm -f $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk.part*
  APK_PATH_PX1_W=$TMPDIR/$RELEASE/sailfish/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  APK_PATH_PX2_W=$TMPDIR/$RELEASE/walleye/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  LIB_PATH_PX1_D=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/lib/arm64/libgdx.so
  LIB_PATH_PX1_B=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/lib/arm64/libgeswallpapers-jni.so
  APK_PATH_PX1_LW1=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk
  APK_PATH_PX1_LW2=$TMPDIR/$RELEASE/sailfish/WallpapersUsTwo/WallpapersUsTwo.apk
  LIB_PATH_PX2_D=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/lib/arm64/libgdx.so
  LIB_PATH_PX2_B=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  APK_PATH_PX2_LW=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt
  cp -af $APK_PATH_PX1_W $MODPATH/system/app/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2017
  cp -af $APK_PATH_PX2_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel/lib/arm64
  cp -af $LIB_PATH_PX1_D $MODPATH/system/app/WallpapersBReel/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX1_B $MODPATH/system/app/WallpapersBReel/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX1_LW1 $MODPATH/system/app/WallpapersBReel/WallpapersBReel.apk
  mkdir -p $MODPATH/system/app/WallpapersUsTwo
  cp -af $APK_PATH_PX1_LW2 $MODPATH/system/app/WallpapersUsTwo/WallpapersUsTwo.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2017/lib/arm64
  cp -af $LIB_PATH_PX2_D $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX2_B $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX2_LW $MODPATH/system/app/WallpapersBReel2017/WallpapersBReel2017.apk
  ;;
  # "crosshatch" for Pixel 3 XL 9.0.0 (PQ2A.190405.003, Apr 2019)
  crosshatch)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/marlin/*' $RELEASE'/taimen/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk.part* > $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk
  rm -f $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk.part*
  cat $TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk.part* > $TMPDIR/$RELEASE/taimen/WallpapersBReel/WallpapersBReel2017.apk
  rm -f $TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk.part*
  APK_PATH_PX1_W=$TMPDIR/$RELEASE/marlin/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  APK_PATH_PX2_W=$TMPDIR/$RELEASE/taimen/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  LIB_PATH_PX1_D=$TMPDIR/$RELEASE/marlin/WallpapersBReel/lib/arm64/libgdx.so
  LIB_PATH_PX1_B=$TMPDIR/$RELEASE/marlin/WallpapersBReel/lib/arm64/libgeswallpapers-jni.so
  APK_PATH_PX1_LW1=$TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk
  APK_PATH_PX1_LW2=$TMPDIR/$RELEASE/marlin/WallpapersUsTwo/WallpapersUsTwo.apk
  LIB_PATH_PX2_D=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/lib/arm64/libgdx.so
  LIB_PATH_PX2_B=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  APK_PATH_PX2_LW=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt
  cp -af $APK_PATH_PX1_W $MODPATH/system/app/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2017
  cp -af $APK_PATH_PX2_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel/lib/arm64
  cp -af $LIB_PATH_PX1_D $MODPATH/system/app/WallpapersBReel/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX1_B $MODPATH/system/app/WallpapersBReel/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX1_LW1 $MODPATH/system/app/WallpapersBReel/WallpapersBReel.apk
  mkdir -p $MODPATH/system/app/WallpapersUsTwo
  cp -af $APK_PATH_PX1_LW2 $MODPATH/system/app/WallpapersUsTwo/WallpapersUsTwo.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2017/lib/arm64
  cp -af $LIB_PATH_PX2_D $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX2_B $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX2_LW $MODPATH/system/app/WallpapersBReel2017/WallpapersBReel2017.apk
  ;;
  # "sargo" for Pixel 3a 9.0.0 (PQ2A.190405.003, Apr 2019)
  sargo)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/sailfish/*' $RELEASE'/walleye/*' $RELEASE'/blueline/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk.part* > $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk
  rm -f $TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk.part*
  cat $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk.part* > $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk
  rm -f $TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk.part*
  cat $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk.part* > $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk
  rm -f $TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk.part*
  APK_PATH_PX1_W=$TMPDIR/$RELEASE/sailfish/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  APK_PATH_PX2_W=$TMPDIR/$RELEASE/walleye/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  APK_PATH_PX3_W=$TMPDIR/$RELEASE/blueline/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  LIB_PATH_PX1_D=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/lib/arm64/libgdx.so
  LIB_PATH_PX1_B=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/lib/arm64/libgeswallpapers-jni.so
  APK_PATH_PX1_LW1=$TMPDIR/$RELEASE/sailfish/WallpapersBReel/WallpapersBReel.apk
  APK_PATH_PX1_LW2=$TMPDIR/$RELEASE/sailfish/WallpapersUsTwo/WallpapersUsTwo.apk
  LIB_PATH_PX2_D=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/lib/arm64/libgdx.so
  LIB_PATH_PX2_B=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  APK_PATH_PX2_LW=$TMPDIR/$RELEASE/walleye/WallpapersBReel2017/WallpapersBReel2017.apk
  APK_PATH_PX3_LW=$TMPDIR/$RELEASE/blueline/WallpapersBReel2018/WallpapersBReel2018.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt
  cp -af $APK_PATH_PX1_W $MODPATH/system/app/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2017
  cp -af $APK_PATH_PX2_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2018
  cp -af $APK_PATH_PX3_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel/lib/arm64
  cp -af $LIB_PATH_PX1_D $MODPATH/system/app/WallpapersBReel/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX1_B $MODPATH/system/app/WallpapersBReel/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX1_LW1 $MODPATH/system/app/WallpapersBReel/WallpapersBReel.apk
  mkdir -p $MODPATH/system/app/WallpapersUsTwo
  cp -af $APK_PATH_PX1_LW2 $MODPATH/system/app/WallpapersUsTwo/WallpapersUsTwo.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2017/lib/arm64
  cp -af $LIB_PATH_PX2_D $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX2_B $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX2_LW $MODPATH/system/app/WallpapersBReel2017/WallpapersBReel2017.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2018
  cp -af $APK_PATH_PX3_LW $MODPATH/system/app/WallpapersBReel2018/WallpapersBReel2018.apk
  ;;
  # "bonito" for Pixel 3a XL 9.0.0 (PQ2A.190405.003, Apr 2019)
  bonito)
  ui_print "- Extracting module files for '"$DEVICE"' and Android Version '"$RELEASE"'"
  unzip -o "$ZIPFILE" $RELEASE'/marlin/*' $RELEASE'/taimen/*' $RELEASE'/crosshatch/*' -d $TMPDIR
  cat $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk.part* > $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk
  rm -f $TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk.part*
  cat $TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk.part* > $TMPDIR/$RELEASE/taimen/WallpapersBReel/WallpapersBReel2017.apk
  rm -f $TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk.part*
  cat $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk.part* > $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk
  rm -f $TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk.part*
  APK_PATH_PX1_W=$TMPDIR/$RELEASE/marlin/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  APK_PATH_PX2_W=$TMPDIR/$RELEASE/taimen/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  APK_PATH_PX3_W=$TMPDIR/$RELEASE/crosshatch/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  LIB_PATH_PX1_D=$TMPDIR/$RELEASE/marlin/WallpapersBReel/lib/arm64/libgdx.so
  LIB_PATH_PX1_B=$TMPDIR/$RELEASE/marlin/WallpapersBReel/lib/arm64/libgeswallpapers-jni.so
  APK_PATH_PX1_LW1=$TMPDIR/$RELEASE/marlin/WallpapersBReel/WallpapersBReel.apk
  APK_PATH_PX1_LW2=$TMPDIR/$RELEASE/marlin/WallpapersUsTwo/WallpapersUsTwo.apk
  LIB_PATH_PX2_D=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/lib/arm64/libgdx.so
  LIB_PATH_PX2_B=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  APK_PATH_PX2_LW=$TMPDIR/$RELEASE/taimen/WallpapersBReel2017/WallpapersBReel2017.apk
  APK_PATH_PX3_LW=$TMPDIR/$RELEASE/crosshatch/WallpapersBReel2018/WallpapersBReel2018.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt
  cp -af $APK_PATH_PX1_W $MODPATH/system/app/NexusWallpapersStubPrebuilt/NexusWallpapersStubPrebuilt.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2017
  cp -af $APK_PATH_PX2_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2017/NexusWallpapersStubPrebuilt2017.apk
  mkdir -p $MODPATH/system/app/NexusWallpapersStubPrebuilt2018
  cp -af $APK_PATH_PX3_W $MODPATH/system/app/NexusWallpapersStubPrebuilt2018/NexusWallpapersStubPrebuilt2018.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel/lib/arm64
  cp -af $LIB_PATH_PX1_D $MODPATH/system/app/WallpapersBReel/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX1_B $MODPATH/system/app/WallpapersBReel/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX1_LW1 $MODPATH/system/app/WallpapersBReel/WallpapersBReel.apk
  mkdir -p $MODPATH/system/app/WallpapersUsTwo
  cp -af $APK_PATH_PX1_LW2 $MODPATH/system/app/WallpapersUsTwo/WallpapersUsTwo.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2017/lib/arm64
  cp -af $LIB_PATH_PX2_D $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libgdx.so
  cp -af $LIB_PATH_PX2_B $MODPATH/system/app/WallpapersBReel2017/lib/arm64/libwallpapers-breel-jni.so
  cp -af $APK_PATH_PX2_LW $MODPATH/system/app/WallpapersBReel2017/WallpapersBReel2017.apk
  mkdir -p $MODPATH/system/app/WallpapersBReel2018
  cp -af $APK_PATH_PX3_LW $MODPATH/system/app/WallpapersBReel2018/WallpapersBReel2018.apk
  ;;
  *)
  ui_print "- Unsupported device."
  ;;
esac

}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
