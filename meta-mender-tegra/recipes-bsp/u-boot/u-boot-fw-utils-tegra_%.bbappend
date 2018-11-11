require recipes-bsp/u-boot/u-boot-fw-utils-mender.inc
require recipes-bsp/u-boot/u-boot-mender-tegra.inc
do_check_mender_defines[noexec]="1"
