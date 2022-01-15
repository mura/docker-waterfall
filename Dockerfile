# syntax=docker/dockerfile:1.3-labs
FROM debian:bullseye-slim

RUN <<EOF
  apt-get update
  apt-get install -y --no-install-recommends \
    curl ca-certificates jq
  rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
  MACHINE=$(uname -m)
  if [ "$MACHINE" = "x86_64" ]; then
    ARCH="x64"
  else
    ARCH=$MACHINE
  fi
  curl -L -X 'GET' \
    "https://api.adoptium.net/v3/binary/latest/17/ga/linux/$ARCH/jre/hotspot/normal/eclipse?project=jdk" \
    -H 'accept: */*' \
    -o jre.tar.gz
  mkdir -p /opt/jre
  tar fxz jre.tar.gz --strip-components=1 -C /opt/jre
  rm jre.tar.gz
EOF

RUN mkdir /app
COPY start /app

ENV PATH /opt/jre/bin:$PATH
ENV VERSION 1.18
ENV BUILD LATEST
ENV PAPER_API https://papermc.io/api/v2/projects/waterfall
ENV JVM_OPTS -Xms512M -Xmx512M -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch
EXPOSE 25577/tcp

VOLUME ["/data"]
WORKDIR /data

ENTRYPOINT [ "/app/start" ]
