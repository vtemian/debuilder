# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based Debian package builder that provides containerized build environments for creating Debian packages across multiple Ubuntu distributions. The project uses shell scripting and Docker to create consistent build environments with all necessary packaging tools pre-installed.

## Common Development Commands

### Using the Makefile

```bash
# Build all Docker images
make build

# Build a specific version (works with any supported version)
make build-focal
make build-jammy
make build-noble
make build-bionic

# Push all images to Docker Hub (requires docker login)
make push

# Build and push all images
make release

# Clean all local images
make clean

# Show available targets
make help
```

### Building Docker Images Manually
```bash
# Build for a specific Ubuntu release
# Supported versions: bionic (18.04), focal (20.04), jammy (22.04), noble (24.04)
docker build -f Dockerfile.bionic -t vtemian/debuilder:bionic .
docker build -f Dockerfile.focal -t vtemian/debuilder:focal .
docker build -f Dockerfile.jammy -t vtemian/debuilder:jammy .
docker build -f Dockerfile.noble -t vtemian/debuilder:noble .

# Build all supported versions
for version in bionic focal jammy noble; do
  docker build -f Dockerfile.$version -t vtemian/debuilder:$version .
done

# Push to Docker Hub (requires docker login)
for version in bionic focal jammy noble; do
  docker push vtemian/debuilder:$version
done
```

### Running the Builder
```bash
# Basic usage - build a Debian package
docker run -v /path/to/source:/source -v /path/to/target:/target vtemian/debuilder:focal

# With GPG signing
docker run \
  -v /path/to/source:/source \
  -v /path/to/target:/target \
  -v /path/to/gpg:/secrets \
  -e GPG_KEY_ID="your-key-id" \
  vtemian/debuilder:focal
```

### Adding Support for New Ubuntu Releases
1. Create a new Dockerfile named `Dockerfile.{codename}` (e.g., `Dockerfile.oracular`)
2. Use the standard template structure from existing Dockerfiles
3. Update the base image to use `buildpack-deps:{codename}-scm`
4. Ensure all required packages are available in the new release

## Architecture and Structure

### Key Components

1. **Dockerfiles**: Each Ubuntu release has its own Dockerfile following the naming pattern `Dockerfile.{codename}`. All Dockerfiles follow the same structure:
   - Base image: `buildpack-deps:{distro}-scm`
   - Install packaging tools via apt
   - Set up non-interactive environment
   - Configure entry point and default command

2. **entrypoint.sh**: Central entry point script that handles:
   - GPG key import from environment variables or mounted secrets
   - Command execution passthrough
   - Located at: entrypoint.sh:1-51

3. **Volume Mounts**:
   - `/source`: Source code to build
   - `/target`: Output directory for built packages
   - `/secrets`: Optional GPG keys for package signing

### Build Process Flow
1. Container starts with entrypoint.sh
2. GPG keys are imported if provided (via environment or secrets mount)
3. Default command `make binary` is executed in `/source`
4. Built packages are output to `/target`

### Environment Configuration
- `DEBUILD_OPTS="-us -uc -b"`: Builds unsigned binary packages by default
- `DEBIAN_FRONTEND=noninteractive`: Ensures non-interactive package installation
- `GPG_KEY_ID` and `GPG_KEY`: Optional environment variables for package signing

## GitHub Actions Workflow

The project includes a GitHub Actions workflow that automatically builds and pushes Docker images:

### Workflow Triggers
- **Push to master/main**: Builds and pushes images when Dockerfiles or entrypoint.sh change
- **Pull requests**: Builds images without pushing (for testing)
- **Weekly schedule**: Rebuilds all images every Monday to include security updates
- **Manual dispatch**: Can be triggered manually from GitHub Actions tab

### Required GitHub Secrets
To enable automatic pushing to Docker Hub, configure these secrets in your repository:
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token (not password)

### Multi-architecture Support
The workflow builds images for both `linux/amd64` and `linux/arm64` platforms.

## Git Workflow

This project follows a feature branch workflow with conventional commits. Follow these guidelines:

### Branch Management
1. **Create feature branches** for each new feature or fix:
   ```bash
   git checkout -b feat/add-new-ubuntu-version
   git checkout -b fix/dockerfile-dependency-issue
   git checkout -b docs/update-readme
   ```

2. **Branch naming conventions**:
   - `feat/description` - New features
   - `fix/description` - Bug fixes
   - `docs/description` - Documentation updates
   - `chore/description` - Maintenance tasks
   - `refactor/description` - Code refactoring

### Conventional Commits
Use conventional commit messages following this format:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring without changing functionality
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes
- `ci`: CI/CD pipeline changes

**Examples:**
```bash
git commit -m "feat: add support for Ubuntu 26.04 LTS"
git commit -m "fix(dockerfile): resolve missing dependency issue"
git commit -m "docs: update installation instructions"
git commit -m "ci: add multi-architecture build support"
```

### Development Workflow
1. **Start new feature**:
   ```bash
   git checkout master
   git pull origin master
   git checkout -b feat/your-feature-name
   ```

2. **Make changes and commit frequently**:
   ```bash
   # Make your changes
   git add .
   git commit -m "feat: add initial Ubuntu 26.04 Dockerfile"
   
   # Continue working
   git add .
   git commit -m "feat: update dependencies for Ubuntu 26.04"
   
   # Push regularly
   git push origin feat/your-feature-name
   ```

3. **Before merging**:
   ```bash
   # Ensure your branch is up to date
   git checkout master
   git pull origin master
   git checkout feat/your-feature-name
   git rebase master
   
   # Final push
   git push origin feat/your-feature-name --force-with-lease
   ```

4. **Create Pull Request** via GitHub interface

### Important Guidelines
- **Never work directly on master** - always use feature branches
- **Commit after each logical change** - don't batch unrelated changes
- **Push regularly** - at least after each commit
- **Test before pushing** - ensure Docker builds work
- **Keep commits atomic** - one logical change per commit
- **Write descriptive commit messages** - explain the "why" not just the "what"

## Development Guidelines

When modifying this project:

1. **Consistency**: Maintain consistent Dockerfile structure across all Ubuntu releases
2. **Dependencies**: Only add packages that are essential for Debian packaging
3. **Testing**: Test new Dockerfiles by building actual Debian packages
4. **GPG Handling**: Never modify the GPG import logic in entrypoint.sh without testing signing functionality