# Tools for the unofficial pfrommerd/nixos-apple-silicon-cache prebuilt
# linux-asahi kernel closures (https://github.com/pfrommerd/nixos-apple-silicon-cache).
#
# It is NOT a Nix substituter -- there's no URL/key to add to nix.settings.
# The cache publishes GitHub Release tarballs tagged with the exact
# nixos-apple-silicon (our `apple-silicon` flake input) revision they were
# built from, roughly daily.
#
# Trust note: this is a single third-party maintainer's unofficial build,
# not an official Nix/Asahi cache. `nix-store --import` runs as root; the
# sha256 check only proves the download wasn't corrupted/tampered in
# transit, not that the upstream build itself is trustworthy. Both tools
# below are meant to be run deliberately, not as part of an unattended
# rebuild.
#
# Plain function (not a NixOS module) so it can be used both as a package in
# environment.systemPackages (nixos/asahi-kernel-cache.nix) AND as a flake
# `packages` output you can `nix run`/`nix build` directly -- the latter
# matters because these tools exist precisely to avoid a from-scratch kernel
# build, so they need to be reachable *before* your first successful
# `nixos-rebuild switch` with this module, not only after.
{ pkgs }:

{
  # Matches flake.lock's *current* apple-silicon pin against the cache.
  # Usually a no-op, since a routine `nix flake update`/`nix-update-kernel`
  # picks whatever apple-silicon HEAD is at that moment, which the cache
  # (daily builds, and only when CI succeeds) has often not caught up to
  # yet. Kept around for the rare case it does line up for free.
  #
  # Usage: import-asahi-kernel-cache [flake-dir, default /etc/nixos]
  importAsahiKernelCache = pkgs.writeShellApplication {
    name = "import-asahi-kernel-cache";
    runtimeInputs = with pkgs; [ curl jq coreutils gnutar zstd ];
    text = ''
      flake_dir="''${1:-/etc/nixos}"
      cache_repo="pfrommerd/nixos-apple-silicon-cache"
      lock_file="$flake_dir/flake.lock"

      if [[ ! -f "$lock_file" ]]; then
        echo "import-asahi-kernel-cache: no flake.lock at $lock_file" >&2
        exit 0
      fi

      rev=$(jq -r '.nodes."apple-silicon".locked.rev // empty' "$lock_file")
      if [[ -z "$rev" ]]; then
        echo "import-asahi-kernel-cache: couldn't read apple-silicon rev from $lock_file" >&2
        exit 0
      fi

      tag="nixos-apple-silicon-$rev"
      echo "import-asahi-kernel-cache: looking for $cache_repo release $tag ..."

      if ! release_json=$(curl -sf "https://api.github.com/repos/$cache_repo/releases/tags/$tag"); then
        echo "import-asahi-kernel-cache: no cached release for apple-silicon rev $rev -- kernel will build locally" >&2
        exit 0
      fi

      archive_url=$(jq -r '.assets[] | select(.name | endswith(".nix-store-export.tar.zst")) | .browser_download_url' <<<"$release_json")
      sha_url=$(jq -r '.assets[] | select(.name | endswith(".nix-store-export.tar.zst.sha256")) | .browser_download_url' <<<"$release_json")

      if [[ -z "$archive_url" || -z "$sha_url" ]]; then
        echo "import-asahi-kernel-cache: release $tag found but missing expected assets, skipping" >&2
        exit 0
      fi

      workdir=$(mktemp -d)
      trap 'rm -rf "$workdir"' EXIT

      archive="$workdir/$(basename "$archive_url")"
      sha_file="$workdir/$(basename "$sha_url")"

      echo "import-asahi-kernel-cache: downloading $(basename "$archive_url") (this is a ~1GB kernel closure)..."
      curl -fL --progress-bar -o "$archive" "$archive_url"
      curl -sfL -o "$sha_file" "$sha_url"

      (cd "$workdir" && sha256sum --check "$(basename "$sha_file")")

      echo "import-asahi-kernel-cache: checksum OK, importing closure into the Nix store (needs sudo)..."
      tar --zstd -xOf "$archive" closure.nix-store-export | sudo nix-store --import >/dev/null

      echo "import-asahi-kernel-cache: done -- run your normal rebuild now, matching store paths will be reused instead of built."
    '';
  };

  # The one you actually want before an update: finds the cache's latest
  # published release (whatever apple-silicon rev it last successfully
  # built, usually within a day or so of upstream), and points flake.lock's
  # apple-silicon *and* nixpkgs inputs at the exact revs the cache built
  # with (via `--override-input`), before importing the matching closure.
  #
  # Both inputs matter, not just apple-silicon: Nix store paths hash the
  # entire build input graph, so if your nixpkgs commit differs from the
  # one the cache built against -- even by a few days on nixos-unstable,
  # where gcc/glibc/etc. churn constantly -- the resulting kernel
  # derivation won't be byte-for-byte the same, and `nixos-rebuild` will
  # rebuild it anyway even though the *version* and *source rev* match.
  # Pinning nixpkgs to the cache's exact commit too is what actually makes
  # the import pay off.
  #
  # Trade-off: this temporarily pulls your whole system's nixpkgs back to
  # whatever the cache last built against (commonly 1-3 weeks behind
  # nixos-unstable), not just the kernel. Since that's still an official
  # channel commit, cache.nixos.org should substitute everything else fine
  # rather than building it locally. Run `nix-update-nixpkgs` whenever
  # you're ready to move back to current.
  #
  # Usage: update-asahi-kernel-cache [flake-dir, default /etc/nixos]
  updateAsahiKernelCache = pkgs.writeShellApplication {
    name = "update-asahi-kernel-cache";
    runtimeInputs = with pkgs; [ curl jq coreutils gnutar zstd nix ];
    text = ''
      flake_dir="''${1:-/etc/nixos}"
      cache_repo="pfrommerd/nixos-apple-silicon-cache"
      lock_file="$flake_dir/flake.lock"

      if [[ ! -f "$lock_file" ]]; then
        echo "update-asahi-kernel-cache: no flake.lock at $lock_file" >&2
        exit 1
      fi

      as_owner=$(jq -r '.nodes."apple-silicon".original.owner // empty' "$lock_file")
      as_repo=$(jq -r '.nodes."apple-silicon".original.repo // empty' "$lock_file")
      if [[ -z "$as_owner" || -z "$as_repo" ]]; then
        echo "update-asahi-kernel-cache: couldn't read the apple-silicon input's owner/repo from $lock_file" >&2
        exit 1
      fi

      npkgs_owner=$(jq -r '.nodes."nixpkgs".original.owner // empty' "$lock_file")
      npkgs_repo=$(jq -r '.nodes."nixpkgs".original.repo // empty' "$lock_file")

      echo "update-asahi-kernel-cache: checking $cache_repo for its latest build..."
      release_json=$(curl -sf "https://api.github.com/repos/$cache_repo/releases/latest") || {
        echo "update-asahi-kernel-cache: couldn't reach the cache repo's releases" >&2
        exit 1
      }

      tag=$(jq -r '.tag_name // empty' <<<"$release_json")
      rev="''${tag#nixos-apple-silicon-}"
      if [[ -z "$tag" || "$rev" == "$tag" ]]; then
        echo "update-asahi-kernel-cache: unexpected release tag '$tag', giving up" >&2
        exit 1
      fi
      published=$(jq -r '.published_at // "unknown"' <<<"$release_json")
      echo "update-asahi-kernel-cache: latest cached build is apple-silicon rev $rev (published $published)"

      archive_url=$(jq -r '.assets[] | select(.name | endswith(".nix-store-export.tar.zst")) | .browser_download_url' <<<"$release_json")
      sha_url=$(jq -r '.assets[] | select(.name | endswith(".nix-store-export.tar.zst.sha256")) | .browser_download_url' <<<"$release_json")
      if [[ -z "$archive_url" || -z "$sha_url" ]]; then
        echo "update-asahi-kernel-cache: release $tag is missing the expected assets, giving up" >&2
        exit 1
      fi

      # Fetch the cache repo's own flake.lock as it stood for this release,
      # to read the exact nixpkgs commit it built against. This is a tiny
      # text file, not the kernel archive -- cheap to check every time.
      cache_nixpkgs_rev=""
      repo_commit=$(jq -r '.target_commitish // empty' <<<"$release_json")
      if [[ -n "$repo_commit" && -n "$npkgs_owner" && -n "$npkgs_repo" ]]; then
        cache_lock_json=$(curl -sf "https://raw.githubusercontent.com/$cache_repo/$repo_commit/flake.lock") || true
        if [[ -n "$cache_lock_json" ]]; then
          cache_nixpkgs_rev=$(jq -r '.nodes.nixpkgs.locked.rev // empty' <<<"$cache_lock_json")
        fi
      fi

      override_args=(--override-input apple-silicon "github:$as_owner/$as_repo/$rev")
      if [[ -n "$cache_nixpkgs_rev" ]]; then
        echo "update-asahi-kernel-cache: cache built against nixpkgs $cache_nixpkgs_rev -- pinning that too for an exact match"
        override_args+=(--override-input nixpkgs "github:$npkgs_owner/$npkgs_repo/$cache_nixpkgs_rev")
      else
        echo "update-asahi-kernel-cache: couldn't determine the cache's nixpkgs pin -- pinning apple-silicon only, import may still miss" >&2
      fi

      workdir=$(mktemp -d)
      trap 'rm -rf "$workdir"' EXIT

      archive="$workdir/$(basename "$archive_url")"
      sha_file="$workdir/$(basename "$sha_url")"

      echo "update-asahi-kernel-cache: downloading $(basename "$archive_url") (this is a ~1GB kernel closure)..."
      curl -fL --progress-bar -o "$archive" "$archive_url"
      curl -sfL -o "$sha_file" "$sha_url"

      (cd "$workdir" && sha256sum --check "$(basename "$sha_file")")

      if tar --zstd -tf "$archive" | grep -qx 'manifest.json'; then
        echo "update-asahi-kernel-cache: build provenance (manifest.json) from the archive:"
        tar --zstd -xOf "$archive" manifest.json
        echo
      fi

      echo "update-asahi-kernel-cache: pinning $lock_file ..."
      nix flake lock "$flake_dir" "''${override_args[@]}"

      echo "update-asahi-kernel-cache: checksum OK, importing closure into the Nix store (needs sudo)..."
      tar --zstd -xOf "$archive" closure.nix-store-export | sudo nix-store --import >/dev/null

      echo "update-asahi-kernel-cache: done. flake.lock now pins apple-silicon (and nixpkgs, if found) to the cache's build revs, and the closure is imported."
      echo "update-asahi-kernel-cache: run your normal rebuild now."
    '';
  };
}
