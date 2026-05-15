FROM alpine:3.20

RUN apk add --no-cache btop ttyd tmux musl-locales musl-locales-lang

ENV LANG=en_US.UTF-8

CMD ["sh", "-c", "tmux new-session -d -s btop btop && exec ttyd -W -p 7681 -t rendererType=dom tmux attach-session -t btop"]