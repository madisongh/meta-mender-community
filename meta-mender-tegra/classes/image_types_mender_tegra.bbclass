inherit image_types_tegra

DATAFILE ?= "${IMAGE_BASENAME}-${MACHINE}.dataimg"

tegraflash_custom_pre() {
    ln -s ${DEPLOY_DIR_IMAGE}/${DATAFILE} ./${DATAFILE}
}

tegraflash_create_flash_config_append() {
    sed -i \
        -e"s,DATAFILE,${DATAFILE}," \
        flash.xml.in
}
