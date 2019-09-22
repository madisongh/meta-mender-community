FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://redundant-boot-reboot-state-script;subdir=${PN}-${PV} \
          file://LICENSE;subdir=${PN}-${PV} \
          "

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

inherit mender-state-scripts

do_compile() {
    cp redundant-boot-reboot-state-script ${MENDER_STATE_SCRIPTS_DIR}/ArtifactReboot_Enter_50
}
