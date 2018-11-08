require recipes-bsp/u-boot/u-boot-fw-utils-mender.inc
require recipes-bsp/u-boot/u-boot-mender-tegra.inc
PACKAGE_EXCLUDE += " u-boot-fw-utils-mender-auto-provided"
do_check_mender_defines[noexec]="1"
