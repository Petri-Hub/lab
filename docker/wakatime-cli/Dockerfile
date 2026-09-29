FROM alpine:3.22

ARG WAKATIME_VERSION

RUN apk add --no-cache ca-certificates \
 && cd /tmp \
 && base="https://github.com/wakatime/wakatime-cli/releases/download/v${WAKATIME_VERSION}" \
 && wget -q "$base/wakatime-cli-linux-amd64.zip" "$base/checksums_sha256.txt" \
 && grep " wakatime-cli-linux-amd64.zip$" checksums_sha256.txt | sha256sum -c - \
 && unzip -q wakatime-cli-linux-amd64.zip \
 && install -m 0755 wakatime-cli-linux-amd64 /usr/local/bin/wakatime-cli \
 && rm -rf /tmp/* \
 && wakatime-cli --version

CMD ["tail", "-f", "/dev/null"]
