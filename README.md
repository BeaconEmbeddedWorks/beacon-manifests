# beacon-manifests

This repository houses the published manifest files supporting the [Beacon Embedded Works](https://www.beaconembeddedworks.com) products.

## Quick Start

### Install the `repo` tool

```bash
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
export PATH="${HOME}/.bin:${PATH}"
```

### Initialize and sync

```bash
mkdir imx-yocto-bsp && cd imx-yocto-bsp
repo init -u https://github.com/BeaconEmbeddedWorks/beacon-manifests -b scarthgap-6.6 -m imx-6.6.36-2.1.0.xml --depth=1
repo sync -c -j$(nproc)
```

### Set up the build environment

```bash
MACHINE=imx93-beacon-kit source setup_beacon.sh -b bld-wayland
```

### Build an image

```bash
bitbake bcn-image-full
```

## Available Manifests

| Manifest | Yocto Release | NXP BSP | Supported Boards |
|----------|--------------|---------|-----------------|
| imx-6.6.36-2.1.0.xml | Scarthgap | 6.6.36_2.1.0 | i.MX93 Beacon Kit |
