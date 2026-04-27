FROM docker.io/zmkfirmware/zmk-build-arm:stable

WORKDIR /app

COPY config/west.yml config/west.yml
COPY zephyr zephyr
COPY boards boards

# West Init
RUN west init -l config
# West Update
RUN west update
# West Zephyr export
RUN west zephyr-export

COPY bin/build.sh ./

CMD ["./build.sh"]
