FILESEXTRAPATHS_prepend := "${THISDIR}/patches:"

MENDER_UBOOT_AUTO_CONFIGURE = "0"
# Use the mmcblk0boot1 partition for uboot environment
MENDER_UBOOT_CONFIG_SYS_MMC_ENV_PART = "2"
# Actual reserved space for bootloader checking purposes in meta layer is 2*BOOTENV_SIZE
MENDER_RESERVED_SPACE_BOOTLOADER_DATA_CHECK = "262144"

SRC_URI += " file://0001-env-tool-add-command-line-option-to-input-lockfile-p.patch"
SRC_URI += " file://0003-tegra-Integration-of-Mender-boot-code-into-U-Boot.patch"
SRC_URI_append_mender-uboot = " file://0010-tegra-mender-auto-configured-modified.patch"
SRC_URI_append_mender-uboot = " file://0011-Jetson-TX2-mender-boot-commands.patch"
SRC_URI_append_mender-uboot = " file://0012-Update-environment-defaults-for-tegra.patch"
SRC_URI_append_mender-uboot = " file://0013-Remove-check-for-CONFIG_SYS_MMC_ENV_PART.patch"
SRC_URI_remove = " file://0003-Integration-of-Mender-boot-code-into-U-Boot.patch"
SRC_URI_remove = " file://0006-env-Kconfig-Add-descriptions-so-environment-options-.patch"
