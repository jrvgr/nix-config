# NixBook peripheral firmware

Referenced by `hosts/nixos/nixbook/default.nix` as
`hardware.asahi.peripheralFirmwareDirectory`. This directory is declared as
a submodule in `.gitmodules` (`git@github.com:jrvgr/nixbook-firmware.git`),
but that repo doesn't exist yet -- this is a plain placeholder until it
does.

Why a separate repo instead of committing the files here: these are Apple's
proprietary per-device firmware blobs (kernelcache, firmware.cpio, etc),
extracted from this specific Mac via the Asahi installer's `asahi-fwextract`
step. There's no canonical public host for them -- Asahi's own tooling has
each user extract their own rather than redistributing centrally, precisely
to avoid redistribution issues. Keeping them out of the main (public)
nix-config repo and in their own repo (recommend making it **private**)
lets you decide per-clone whether to pull them in, the same way `nvim` is
already handled here.

To finish wiring this up:

1. Create `jrvgr/nixbook-firmware` on GitHub (private recommended).
2. Push the contents of `/etc/nixos/firmware/` on NixBook to it.
3. From the nix-config repo root:
   ```
   git submodule add git@github.com:jrvgr/nixbook-firmware.git hosts/nixos/nixbook/firmware
   ```
   (replaces this placeholder with a real submodule pointer)
4. Commit and push.
