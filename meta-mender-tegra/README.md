# Mender integration for NVIDIA Tegra

This layer contains [mender](https://mender.io/) specific integrations for NVIDIA Tegra hardware, for Over The Air (OTA) software update support of Yocto based NVIDIA Tegra builds.

It depends on the [meta-tegra](https://github.com/madisongh/meta-tegra) layer with branch matching the selected branch name.

See integration details in the [Mender Hub Page](https://hub.mender.io/t/nvidia-tegra-jetson-tx2/123)

Supported and Tested Boards:
* Jetson TX2 Development Board

### Build
Download the source:

    $ mkdir mender-tegra
    $ cd mender-tegra
    $ repo init \
            -u https://github.com/mendersoftware/meta-mender-community \
            -m meta-mender-tegra/scripts/manifest-tegra.xml \
            -b warrior
    $ repo sync

Setup environment

    $ . setup-environment tegra

Build

    $ bitbake core-image-base

## Customizing Image Rootfs Size

To customize the size reserved for your rootfs, add variable MENDER_STORAGE_TOTAL_SIZE_MB to your build/local.conf or image and define with a value which is twice the size of your desired rootfs in MB.

## Upgrades from branches earlier than warrior

The warrior branch adds several changes which:
1) Cleanup variable references related to rootfs size and make it possible to arbitrarily grow the rootfs as described in the previous section.  Previous rootfs sizes were limited based on u-boot 
environment storage location.  See [this conversation](https://hub.mender.io/t/u-boot-environment-located-past-0xffffffff-fails/861/9) on mender hub.
2) Support [redundant boot](https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%2520Linux%2520Driver%2520Package%2520Development%2520Guide%2Fbootloader_update.html%23) for bootloader components using
nvidia tools and images.  See [this issue](https://github.com/madisongh/meta-tegra/issues/178) for background.
* The redundant boot components are upgraded through a mender reboot state script.  This means the upgrades are not performed during manual install.  To perform reboot state script updates using manual install, the mender-install-manual script is provided. Run this script with the same arguments you would provide to mender -install.  The system will include reboot state script content after performing the update.

Both of these changes above require changes to the u-boot environment location, which are outlined in the mender hub conversation linked above and also 
[this post](https://devtalk.nvidia.com/default/topic/1063652/jetson-tx2/mmcblk0boot1-usage-at-address-4177408-and-u-boot-parameter-storage-space-availability/) on the nvidia forum about my observation related to mmcblkboot1.  
This means upgrade from sumo or thud would require changes to move u-boot environment location and most likely would also require redundant boot support implemented as a post update state script similar to what
is done on the warrior branch but also including additional payload and tools from earlier branches to support redundant boot.  I have not actually attempted this yet myself.
