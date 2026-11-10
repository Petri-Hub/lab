# Hermes media patch

`hermes-media.patch` is the live patch rebased against the Hermes image used on 2026-11-10. It enables Modal sandbox file delivery and protects credential paths. The Telegram delivery test succeeded with this patch active.

This tracked copy is a backup, not the startup source. The container's startup script applies `/opt/data/patches/*.patch` from persistent storage. When upgrading Hermes, check the patch against the new image and update both copies if it needs rebasing.
