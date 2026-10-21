#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

# Inherit from Go7 device
$(call inherit-product, device/onyx/Go7/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Boot animation
TARGET_SCREEN_HEIGHT := 1680
TARGET_SCREEN_WIDTH := 1264

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := lineage_Go7
PRODUCT_DEVICE := Go7
PRODUCT_BRAND := Onyx
PRODUCT_MODEL := Go7
PRODUCT_MANUFACTURER := ONYX

PRODUCT_CHARACTERISTICS := tablet,nosdcard

PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceProduct=Go7
