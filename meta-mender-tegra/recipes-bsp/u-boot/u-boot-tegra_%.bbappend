require recipes-bsp/u-boot/u-boot-mender.inc
require recipes-bsp/u-boot/u-boot-mender-tegra.inc

do_install_append() {
    install -d ${D}/opt/ota_package/
    install -m 0644 ${DEPLOY_DIR_IMAGE}/u-boot-jetson-tx2.bin.bup-payload ${D}/opt/ota_package/bl_update_payload_current
    ln -s /opt/ota_package/bl_update_payload_current ${D}/opt/ota_package/bl_update_payload
}

do_install[depends] += "u-boot-bup-payload:do_deploy"
FILES_${PN} += "/opt/ota_package/bl_update_payload_current"
FILES_${PN} += "/opt/ota_package/bl_update_payload"
RDEPENDS_${PN} += "tegra186-redundant-boot"
RDEPENDS_${PN} += "tegra-state-scripts"
