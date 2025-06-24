# Debuilder - Docker-based Debian Package Builder

[![Build and Push Docker Images](https://github.com/vtemian/debuilder/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/vtemian/debuilder/actions/workflows/docker-build-push.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/vtemian/debuilder.svg)](https://hub.docker.com/r/vtemian/debuilder)

Debuilder provides Docker containers for building Debian packages across multiple Ubuntu distributions. It offers consistent, isolated build environments with all necessary packaging tools pre-installed.

## Features

- 🐳 Pre-configured Docker containers for building Debian packages
- 📦 Support for multiple Ubuntu LTS versions (18.04, 20.04, 22.04, 24.04)
- 🔐 GPG signing support for secure package distribution
- 🏗️ Multi-architecture builds (AMD64 and ARM64)
- 🔄 Weekly automated rebuilds for security updates
- 🛠️ All essential Debian packaging tools included

## Quick Start

### Using Pre-built Images

```bash
# Pull the image for your target Ubuntu version
docker pull vtemian/debuilder:focal

# Build your Debian package
docker run -v $(pwd):/source -v $(pwd)/output:/target vtemian/debuilder:focal
```

### Available Tags

- `vtemian/debuilder:bionic` - Ubuntu 18.04 LTS
- `vtemian/debuilder:focal` - Ubuntu 20.04 LTS
- `vtemian/debuilder:jammy` - Ubuntu 22.04 LTS
- `vtemian/debuilder:noble` - Ubuntu 24.04 LTS

## Usage

### Basic Package Building

```bash
# Mount your source code and output directory
docker run \
  -v /path/to/source:/source \
  -v /path/to/output:/target \
  vtemian/debuilder:focal
```

### With GPG Signing

```bash
# Using environment variables
docker run \
  -v /path/to/source:/source \
  -v /path/to/output:/target \
  -e GPG_KEY_ID="your-key-id" \
  -e GPG_KEY="$(cat ~/.gnupg/private-key.asc)" \
  vtemian/debuilder:focal

# Using mounted secrets
docker run \
  -v /path/to/source:/source \
  -v /path/to/output:/target \
  -v ~/.gnupg:/secrets \
  -e GPG_KEY_ID="your-key-id" \
  vtemian/debuilder:focal
```

### Custom Build Commands

```bash
# Override the default build command
docker run \
  -v $(pwd):/source \
  -v $(pwd)/output:/target \
  vtemian/debuilder:focal \
  make custom-target
```

## Building from Source

### Prerequisites

- Docker
- Make (optional, for convenience)

### Build Images Locally

```bash
# Clone the repository
git clone https://github.com/vtemian/debuilder.git
cd debuilder

# Build all images
make build

# Build a specific version
make build-focal

# Build and push to Docker Hub
make release
```

### Manual Docker Build

```bash
# Build a specific Ubuntu version
docker build -f Dockerfile.focal -t vtemian/debuilder:focal .
```

## Volume Mounts

| Mount Point | Purpose |
|------------|---------|
| `/source` | Source code directory containing debian/ folder |
| `/target` | Output directory for built .deb packages |
| `/secrets` | Optional: GPG keys for package signing |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUILD_OPTS` | Options passed to debuild | `-us -uc -b` |
| `GPG_KEY_ID` | GPG key ID for package signing | None |
| `GPG_KEY` | GPG private key content | None |

## Included Tools

Each container includes:

- `build-essential` - Essential compilation tools
- `devscripts` - Debian package development scripts
- `debhelper` - Helper programs for debian/rules
- `equivs` - Tool to create dummy packages
- `quilt` - Patch management system
- `dh-autoreconf` - Debhelper autoreconf integration
- `dh-python` - Debian helper tools for Python packages
- `python3-sphinx` - Documentation generator
- And more...

## CI/CD Integration

### GitHub Actions

The repository includes a workflow that automatically builds and pushes images. To use it in your fork:

1. Fork this repository
2. Add Docker Hub credentials as GitHub secrets:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
3. Images will be built automatically on push

### GitLab CI

Example `.gitlab-ci.yml`:

```yaml
build-package:
  image: vtemian/debuilder:focal
  script:
    - make binary
  artifacts:
    paths:
      - "*.deb"
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Adding Support for New Ubuntu Versions

1. Create a new Dockerfile: `Dockerfile.{codename}`
2. Add the version to `VERSIONS` in the Makefile
3. Update the GitHub Actions workflow matrix
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Maintainers

- Vlad Temian ([@vtemian](https://github.com/vtemian))
- Presslabs Team ([@presslabs](https://github.com/presslabs))

## Acknowledgments

Built with ❤️ by [Presslabs](https://www.presslabs.com/)