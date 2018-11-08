# Overview

This layer contains [mender](https://mender.io/) specific integrations for NVIDIA Tegra hardware, for Over The Air (OTA) software update support of Yocto based NVIDIA Tegra hardware.

It depends on the [meta-tegra](https://github.com/madisongh/meta-tegra) layer with branch matching the selected branch name.  Until [this pull request](https://github.com/madisongh/meta-tegra/pull/114) is resolved it will be necessary to use the repository/branch [here](https://github.com/Trellis-Logic/meta-tegra/tree/add-data-partition-support).

## Tested Platforms

* Jetson TX2 Development Board

# Using

The easiest way to test run is to use the project at [yocto-tegra](https://github.com/Trellis-Logic/yocto-tegra) where all of these steps are already complete.

For detailed instructions to incorporate with your yocto project build, see below.

1. Clone this project and meta-tegra into a local directory within your Yocto project
2. Use bitbake-layers add-layer or edit your build/conf/bblayers.conf file to include both meta-tegra and this project.
3. Set appropriate variables into your build/conf/local.conf file or a custom image file.  Here are a list of parameters needed, customized for the Jetson TX2 developemnt board:
```
# This sets the default machine to be qemux86 if no other machine is selected:
MACHINE ??= "jetson-tx2"
# meta-tegra
IMAGE_CLASSES += "image_types_tegra"
IMAGE_FSTYPES += "tegraflash"
```
These select the appropriate target hardware and image types for the meta-tegra project.  See instructions at [this link](https://github.com/madisongh/meta-tegra/wiki/Flashing-the-Jetson-Dev-Kit).
```
# 
MENDER_ARTIFACT_NAME = "release-1"
INHERIT += "mender-full"
# Yocto Sumo (2.5) or newer mender settings
PREFERRED_VERSION_pn-mender = "1.1.%"
PREFERRED_VERSION_pn-mender-artifact = "2.0.%"
PREFERRED_VERSION_pn-mender-artifact-native = "2.0.%"
ARTIFACTIMG_FSTYPE = "ext4"
MENDER_STORAGE_DEVICE = "/dev/mmcblk0"
MENDER_FEATURES_ENABLE_append = " mender-uboot mender-image-sd"
# Generate dataimg for use with tegraflash
IMAGE_TYPEDEP_tegraflash += " dataimg"
IMAGE_FSTYPES += "dataimg"
# Additional mender settings, See discussion in VS-68
EXTRA_IMAGECMD_ext4 = " -b 2048"
PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-fw-utils-tegra"
PREFERRED_RPROVIDER_u-boot-fw-utils = "u-boot-fw-utils-tegra"
# Use 3G rootfs max size, setup for 4 GB total size
# TODO: finalize partition sizes later
IMAGE_ROOTFS_MAXSIZE = "3000000000"
MENDER_STORAGE_TOTAL_SIZE_MB = "4000"
# Note: this isn't really a boot file, just put it here to keep the mender build from
# complaining about empty IMAGE_BOOT_FILES.  We won't use the full image anyway, just the mender file
IMAGE_BOOT_FILES = "u-boot-dtb.bin"
# Mender customizations to support jetson tx2.  This needs to match up with flash_l4t_t186.custom.xml scheme
# We don't use a boot partition
MENDER_BOOT_PART = ""
MENDER_DATA_PART = "${MENDER_STORAGE_DEVICE_BASE}30"
MENDER_ROOTFS_PART_A = "${MENDER_STORAGE_DEVICE_BASE}1"
MENDER_ROOTFS_PART_B = "${MENDER_STORAGE_DEVICE_BASE}29"
# See setting in meta-tegra/conf/machine
ROOTFSPART_SIZE = "${IMAGE_ROOTFS_MAXSIZE}"
# See setting in https://github.com/madisongh/meta-tegra/blob/ba572dad0fe5bb01f1655115f60fca07e20bf16c/recipes-kernel/linux/linux-tegra_4.4.bb#L25
# This should probably be moved into a bbappends file
KERNEL_ROOTSPEC = "root=/dev/mmcblk\${devnum}p\${distro_bootpart} rw rootwait"
# Assumes a default partition layout for jetson with partition 28 reserved for uboot environment
# At LBA 0x68b170.  Use mmc part command in u-boot to find partition start
MENDER_UBOOT_ENV_STORAGE_DEVICE_OFFSET = "3512918016"
MENDER_RESERVED_SPACE_BOOTLOADER_DATA = "262144"
# Use a 4096 byte alignment for support of tegraflash scheme and default partition locations
MENDER_PARTITION_ALIGNMENT = "4096"
DISTRO_FEATURES_append = " systemd"
VIRTUAL-RUNTIME_init_manager = " systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED = " sysvinit"
VIRTUAL-RUNTIME_initscripts = ""
```
These are settings related to mender configuration which:
* Select the emmc part as the target for code storage
* Enables mender u-boot and sd support
* Adds support for dataimg generation
* Sets custom u-boot-fw-utils provider with support for tegra
* Uses a 30GB rootfs
* Sets a dummy value for IMAGE_BOOT_FILES, we won't use the mender created .sdimage for flashing but instead use tegraflash provided by meta-tegra
* Uses a data partition at partition offset 30, and rootfsa/b partitions at offset 1 and 29.  These are chosen to make minimal modifications to the [default Jetson partition layout](https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Fpart_config_jetson_xavier.html%23wwpID0EGHA) while still supporting the 3 partitions needed for mender.  Settings here need to match settings in [recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml](recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml).
* Uses a uboot environment stored in partition uboot-env within [recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml](recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml), calculated based on byte offset.  This needs to be updated whenever the partition layout changes.  The easiest way to find this is to boot into the u-boot console, type mmc part to list partitions, then multiply the LBA value for u-boot env by 512 and save this as MENDER_UBOOT_ENV_STORAGE_DEVICE_OFFSET.
* Sets up to use systemd which is the default init system for mender.

# Testing Local Mender Deployment
After running the build, scp the mender target to your host:
```
scp build/tmp/deploy/images/jetson-tx2/core-image-minimal-jetson-tx2.mender root@device-ip-address:/tmp/
```
Then ssh into the target and run the mender -rootfs command followed by reboot
```
mender -rootfs /tmp/core-image-minimal-jetson-tx2.mender
reboot
```
You can also use the Mender [integration checklist](https://docs.mender.io/1.6/devices/integrating-with-u-boot/integration-checklist) to verify each component of your mender installation is working properly.

