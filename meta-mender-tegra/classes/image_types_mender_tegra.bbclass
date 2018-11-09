inherit image_types_tegra

DATAFILE ?= "${IMAGE_BASENAME}-${MACHINE}.dataimg"

tegraflash_custom_pre_append() {
    ln -s ${DEPLOY_DIR_IMAGE}/${DATAFILE} ./${DATAFILE}
}

tegraflash_create_flash_config_append_tegra201() {
    cat "${STAGING_DATADIR}/tegraflash/flash_${MACHINE}.xml" | sed \
        -e"s,DATAFILE,${DATAFILE}," \
        > flash.xml.in
}

tegraflash_create_flash_config_append_tegra186() {
    cat "${STAGING_DATADIR}/tegraflash/flash_${MACHINE}.xml" | sed \
        -e"s,DATAFILE,${DATAFILE}," \
        > flash.xml.in
}

