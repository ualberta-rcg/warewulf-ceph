<img src="https://www.ualberta.ca/en/toolkit/media-library/homepage-assets/ua_logo_green_rgb.png" alt="University of Alberta Logo" width="50%" />

# Warewulf Ceph Node Image

[![CI/CD](https://github.com/ualberta-rcg/warewulf-ceph/actions/workflows/deploy-warewulf-ceph.yml/badge.svg)](https://github.com/ualberta-rcg/warewulf-ceph/actions/workflows/deploy-warewulf-ceph.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/rkhoja/warewulf-ceph?style=flat-square)
![Docker Image Size](https://img.shields.io/docker/image-size/rkhoja/warewulf-ceph/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

**Maintained by:** Rahim Khoja ([khoja1@ualberta.ca](mailto:khoja1@ualberta.ca)) & Karim Ali ([kali2@ualberta.ca](mailto:kali2@ualberta.ca))

## 🧰 Description

This repository contains a hardened **Ceph node image** based on Ubuntu 22.04, built into a Docker container that is **Warewulf-compatible** and deployable on bare metal.

It's primarily used for imaging and provisioning Ceph storage nodes using [Warewulf 4](https://warewulf.org) in high-performance computing and research storage clusters.

The image includes the full Ceph stack (MON, MGR, OSD, MDS, RGW) and CIS security hardening using the SCAP Security Guide.

The image is automatically built and pushed to Docker Hub using GitHub Actions whenever changes are pushed to the `latest` branch.

## 📦 Docker Image

**Docker Hub:** [rkhoja/warewulf-ceph:latest](https://hub.docker.com/r/rkhoja/warewulf-ceph)

```bash
docker pull rkhoja/warewulf-ceph:latest
````

## 🏗️ What's Inside

This container includes:

* **Ceph Quincy** (installed from official Ceph repos)
* All Ceph daemons: `ceph-mon`, `ceph-mgr`, `ceph-osd`, `ceph-mds`, `radosgw`
* SSH, NFS client, LVM, SMART tools, NVMe CLI
* Filesystem utilities: Btrfs, XFS, ext4, ZFS-ready kernel modules (if required)
* SCAP CIS Level 2 hardening (automatically applied)
* Systemd-based boot compatible with Warewulf PXE deployments
* Pre-created `ceph` user (UID/GID 167) with correct directory permissions
* `changeme` root password (change in production!)

**Ceph** ([docs](https://docs.ceph.com/en/latest/)) is ready for manual cluster bootstrapping or integration with `cephadm`.

## 🛠️ GitHub Actions - CI/CD Pipeline

This project includes a GitHub Actions workflow: `.github/workflows/deploy-warewulf-ceph.yml`.

### 🔄 What It Does

* Builds the Docker image from the `Dockerfile`
* Logs into Docker Hub using stored GitHub Secrets
* Pushes the image tagged as the current branch (usually `latest`)

### ✅ Setting Up GitHub Secrets

To enable pushing to your Docker Hub:

1. Go to your fork's GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add the following:

   * `DOCKER_HUB_REPO` → your Docker Hub repo. In this case: *rkhoja/warewulf-ceph*
   * `DOCKER_HUB_USER` → your Docker Hub username
   * `DOCKER_HUB_TOKEN` → create a [Docker Hub access token](https://hub.docker.com/settings/security)

### 🚀 Manual Trigger & Auto-Build

* Manual: Run the workflow from the **Actions** tab with **Run workflow** (enabled via `workflow_dispatch`).

* Automatic: Any push to the `latest` branch triggers the CI/CD pipeline.

* **Recommended branching model:**

  * Work and test in `main`
  * Merge or fast-forward `main` to `latest` to trigger a production build

```bash
git checkout latest
git merge main
git push origin latest
```

## 🧪 How To Use This Image with Warewulf 4

Once you have Warewulf 4 setup on your control node:

```bash
wwctl image import --build --force docker://rkhoja/warewulf-ceph:latest ceph
```

### Warewulf Configuration

Warewulf overlays included are examples. It assumes only one IP for each node. Profiles were configured in Warewulf as follows:

PUT STUFF HERE 

## 🤝 Support

Many Bothans died to bring us this information. This project is provided as-is, but reasonable questions may be answered based on my coffee intake or mood. ;)

Feel free to open an issue or email **[khoja1@ualberta.ca](mailto:khoja1@ualberta.ca)** or **[kali2@ualberta.ca](mailto:kali2@ualberta.ca)** for U of A related deployments.

## 📜 License

This project is released under the **MIT License** - one of the most permissive open-source licenses available.

**What this means:**
- ✅ Use it for anything (personal, commercial, whatever)
- ✅ Modify it however you want
- ✅ Distribute it freely
- ✅ Include it in proprietary software

**The only requirement:** Keep the copyright notice somewhere in your project.

That's it! No other strings attached. The MIT License is trusted by major projects worldwide and removes virtually all legal barriers to using this code.

**Full license text:** [MIT License](./LICENSE)

## 🧠 About University of Alberta Research Computing

The [Research Computing Group](https://www.ualberta.ca/en/information-services-and-technology/research-computing/index.html) supports high-performance computing, data-intensive research, and advanced infrastructure for researchers at the University of Alberta and across Canada.

We help design and operate compute environments that power innovation — from AI training clusters to national research infrastructure.

