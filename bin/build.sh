#!/usr/bin/env bash

set -eu

PWD=$(pwd)
TIMESTAMP="${TIMESTAMP:-$(date -u +"%Y%m%d%H%M")}"
COMMIT="${COMMIT:-$(echo xxxxxx)}"

# ZMK_EXTRA_MODULES points at the user-config repo so Zephyr discovers the
# boards/ directory via user_config/zephyr/module.yml's board_root setting.
# Keeping the user repo separate from the ZMK workspace at /app avoids
# Kconfig recursion when Zephyr scans modules.
# See: https://zmk.dev/docs/development/local-toolchain/build-flash#building-with-external-modules
USER_CONFIG="${PWD}/user_config"

# West Build (left)
west build -s zmk/app -p -d build/left -b adv360_left -S studio-rpc-usb-uart -- \
    -DZMK_CONFIG="${USER_CONFIG}/config" \
    -DZMK_EXTRA_MODULES="${USER_CONFIG}" \
    -DCONFIG_ZMK_STUDIO=y
# Adv360 Left Kconfig file
grep -vE '(^#|^$)' build/left/zephyr/.config
# Rename zmk.uf2
cp build/left/zephyr/zmk.uf2 "./firmware/${TIMESTAMP}-${COMMIT}-left-clique.uf2"

# Build right side if selected
if [ "${BUILD_RIGHT}" = true ]; then
    # West Build (right)
    west build -s zmk/app -p -d build/right -b adv360_right -- \
        -DZMK_CONFIG="${USER_CONFIG}/config" \
        -DZMK_EXTRA_MODULES="${USER_CONFIG}"
    # Adv360 Right Kconfig file
    grep -vE '(^#|^$)' build/right/zephyr/.config
    # Rename zmk.uf2
    cp build/right/zephyr/zmk.uf2 "./firmware/${TIMESTAMP}-${COMMIT}-right-clique.uf2"
fi
