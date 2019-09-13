# See https://devtalk.nvidia.com/default/topic/1036443/u-boot-error-when-loading-custom-device-tree-from-boot-with-extlinux-conf/
# Allows use with extlinux.conf to load updated dtb file from rootfs
EXTRA_OEMAKE += "DTC_FLAGS='-a 524288'"
