FROM mrcreativ3001/moonlight-web-stream:v3.0.1

USER root
RUN apt-get update && apt-get install -y --no-install-recommends python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*
USER moonlight
