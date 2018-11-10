# Mender integration for NVIDIA Tegra

This layer contains [mender](https://mender.io/) specific integrations for NVIDIA Tegra hardware, for Over The Air (OTA) software update support of Yocto based NVIDIA Tegra builds.

It depends on the [meta-tegra](https://github.com/madisongh/meta-tegra) layer with branch matching the selected branch name.  Until [this pull request](https://github.com/madisongh/meta-tegra/pull/114) is resolved it will be necessary to use the repository/branch [here](https://github.com/Trellis-Logic/meta-tegra/tree/add-data-partition-support).

Supported and Tested Boards:
* Jetson TX2 Development Board

### Build
Download the source:

    $ mkdir mender-tegra
    $ cd mender-tegra
    $ repo init \
            -u https://github.com/mendersoftware/meta-mender-community \
            -m meta-mender-tegra/scripts/manifest-tegra.xml \
            -b sumo
    $ repo sync

Setup environment

    $ . setup-environment tegra

Build

    $ bitbake core-image-base

### Deploying

Set the device into recovery mode by power cycling the device, then holding down reset and recovery buttons, release reset, then release recovery.  Connect the USB cable on the dev board to the host.

Then use

    $ ./deploy.sh

To deploy to the target using tegraflash zip file.

### Testing Local Mender Deployment
After running the build, scp the mender target to your host using the default root account and no password:
```
scp build/tmp/deploy/images/jetson-tx2/core-image-base-jetson-tx2.mender root@device-ip-address:/tmp/
```
Then ssh into the target and run the mender -rootfs command followed by reboot
```
mender -rootfs /tmp/core-image-base-jetson-tx2.mender
reboot
```
You can also use the Mender [integration checklist](https://docs.mender.io/1.6/devices/integrating-with-u-boot/integration-checklist) to verify each component of your mender installation is working properly.

### Mender Configuration Variables

The local.conf file will be populated with variables which:
* Select the emmc part as the target for code storage
* Enables mender u-boot and sd support
* Adds support for dataimg generation
* Sets custom u-boot-fw-utils provider with support for tegra
* Uses a 30GB rootfs
* Sets a dummy value for IMAGE_BOOT_FILES, we won't use the mender created .sdimage for flashing but instead use tegraflash provided by meta-tegra
* Uses a data partition at partition offset 30, and rootfsa/b partitions at offset 1 and 29.  These are chosen to make minimal modifications to the [default Jetson partition layout](https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Fpart_config_jetson_xavier.html%23wwpID0EGHA) while still supporting the 3 partitions needed for mender.  Settings here need to match settings in [recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml](recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml), and you will need to modify this file to correspond to the flash layout on the part you are supprting, if not the tegra 186.  I'd welcome contributions here from anyone using different hardware.
* Uses a uboot environment stored in partition uboot-env within [recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml](recipes-bsp/tegra-binaries/files/flash_l4t_t186.custom.xml), calculated based on byte offset.  This needs to be updated whenever the partition layout changes.  The easiest way to find this is to boot into the u-boot console, type mmc part to list partitions, then multiply the LBA value for u-boot env by 512 and save this as MENDER_UBOOT_ENV_STORAGE_DEVICE_OFFSET.
** Note: I used a dedicated sector for environment storage instead of mmcblk0boot initially by accident but have not attempted to modify due to 1) concerns about support for mmcblk0boot partition on [the mender forum](https://groups.google.com/a/lists.mender.io/d/msg/mender/ISaA1ll9Fbo/SDmSOTsQBAAJ) and 2) Issues with redundancy support in mmcblk0boot mentioned on [meta-tegra](https://github.com/madisongh/meta-tegra/pull/114).
* Sets up to use systemd which is the default init system for mender.
* Adds ssh support to eliminate the need to connect a serial port cable or monitor to the development board.
