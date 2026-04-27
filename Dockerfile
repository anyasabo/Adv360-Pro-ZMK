FROM docker.io/zmkfirmware/zmk-build-arm:stable

WORKDIR /app

# /app is the west workspace topdir. Per config/west.yml's self.path: config,
# west needs a config/west.yml here so it can resolve the workspace and let
# `west update` populate sibling projects (zmk, zephyr, modules) at /app/zmk,
# /app/zephyr, etc. We only copy the manifest — the full user config is staged
# separately at /app/user_config below.
COPY config/west.yml config/west.yml

# The user-config (Zephyr-module) repo lives at /app/user_config. Its
# zephyr/module.yml is discovered via -DZMK_EXTRA_MODULES at build time, and
# its config/ dir is passed to -DZMK_CONFIG. Keeping it separate from the west
# workspace at /app prevents Kconfig recursion when Zephyr scans modules.
COPY config user_config/config
COPY zephyr user_config/zephyr
COPY boards user_config/boards

RUN west init -l config
RUN west update
RUN west zephyr-export

COPY bin/build.sh ./

CMD ["./build.sh"]
