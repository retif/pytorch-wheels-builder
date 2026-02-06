# Setup Guide

## Quick Start

1. **Create GitHub Repository**

```bash
gh repo create pytorch-wheels-builder --public --description "Custom PyTorch wheels for Python 3.13 + CUDA 13.0"
```

2. **Initialize and Push**

```bash
cd /home/oleks/projects/pytorch-wheels-builder
git init
git add .
git commit -m "Initial commit: PyTorch wheels builder for Python 3.13 + CUDA 13.0"
git branch -M main
git remote add origin https://github.com/retif/pytorch-wheels-builder.git
git push -u origin main
```

3. **Trigger Builds**

Go to GitHub Actions and manually trigger:
- "Build Nunchaku Wheel"
- "Build Flash Attention Wheel"
- "Build SageAttention Wheel"

Or use the "Build All Wheels" workflow to trigger all three at once.

## GitHub Actions Requirements

The workflows require:
- **ubuntu-latest** runner (provided by GitHub)
- **CUDA toolkit** (installed via actions)
- **Python 3.13** (installed via actions/setup-python@v5)

No secrets or additional configuration needed - it uses the automatic `GITHUB_TOKEN`.

## Build Process

Each workflow:
1. Sets up Python 3.13
2. Installs CUDA 13.0 toolkit
3. Installs PyTorch 2.10.0+cu130
4. Clones the source repository
5. Builds the wheel from source
6. Tests the wheel
7. Creates a GitHub Release
8. Uploads the wheel as an artifact

## Using the Wheels

### In ComfyUI Dockerfile

Add to `/home/oleks/projects/ComfyUI-Docker/cu130-megapak-pt210/Dockerfile`:

```dockerfile
# Performance optimization libraries
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
# Nunchaku (binary pair with PyTorch)
https://github.com/retif/pytorch-wheels-builder/releases/download/nunchaku-v1.0.2-py313-cu130/nunchaku-1.0.2+torch2.10-cp313-cp313-linux_x86_64.whl \
# FlashAttention (binary pair with PyTorch & CUDA)
https://github.com/retif/pytorch-wheels-builder/releases/download/flash-attn-v2.8.2-py313-cu130/flash_attn-2.8.2+cu130torch2.10-cp313-cp313-linux_x86_64.whl \
# SageAttention
https://github.com/retif/pytorch-wheels-builder/releases/download/sageattention-v2.2.0-py313-cu130/sageattention-2.2.0-cp313-cp313-linux_x86_64.whl
```

### Manual Installation

```bash
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/<tag>/<wheel-name>.whl
```

## Updating Versions

To build new versions, trigger the workflows manually with updated version inputs:

1. Go to **Actions** tab
2. Select the workflow (e.g., "Build Nunchaku Wheel")
3. Click **Run workflow**
4. Enter the new version
5. Click **Run workflow** button

## Troubleshooting

### Build Fails

Check:
- CUDA architecture is correct (8.9 for RTX 4090)
- PyTorch version is compatible
- Source repository has the specified version/tag

### Wheel Not Compatible

Ensure:
- Python version matches: cp313 = Python 3.13
- Platform matches: linux_x86_64
- CUDA version matches: cu130 = CUDA 13.0

### Installation Fails

Verify:
- PyTorch 2.10.0+cu130 is installed first
- CUDA 13.0 runtime is available
- System has compatible glibc version

## Architecture Support

Current builds target:
- **CUDA Arch 8.9** (RTX 4090, RTX 4080)

To build for other GPUs, update `TORCH_CUDA_ARCH_LIST` in workflows:
- 7.5: RTX 2080, Titan RTX
- 8.0: A100
- 8.6: RTX 3090, RTX 3080
- 8.9: RTX 4090, RTX 4080
- 9.0: H100

## CI/CD Pipeline

```
Manual Trigger / Schedule
         ↓
   GitHub Actions
         ↓
  CUDA Toolkit Install
         ↓
   Build from Source
         ↓
    Test Wheel
         ↓
  Create Release
         ↓
   Upload Artifacts
```

## Cost

- **$0** - Uses free GitHub Actions minutes for public repositories
- Build time: ~15-30 minutes per wheel
- Storage: Wheels stored in GitHub Releases (free for public repos)
