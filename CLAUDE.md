# PyTorch Wheels Builder Project

This repository builds custom binary wheels for Python 3.13/3.14 + PyTorch 2.10.0 + CUDA 13.0 for packages that don't have official wheels for these versions.

## Project Structure

```
.github/workflows/
├── build-nunchaku-py313.yml        # Python 3.13 build
├── build-nunchaku-py314.yml        # Python 3.14 build
├── build-flash-attention-py313.yml # Python 3.13 build
├── build-flash-attention-py314.yml # Python 3.14 build
├── build-sageattention-py313.yml   # Python 3.13 build
├── build-sageattention-py314.yml   # Python 3.14 build
├── build-cupy-cuda13x-py313.yml    # Python 3.13 build
└── build-cupy-cuda13x-py314.yml    # Python 3.14 build
```

## Release Tag Format

**IMPORTANT**: All releases must use this tag format:
```
{package}-v{version}-py{313|314}-torch{pytorch_version}-cu130
```

Examples:
- `nunchaku-v1.0.2-py313-torch2.10.0-cu130`
- `flash-attn-v2.8.2-py314-torch2.10.0-cu130`
- `sageattention-v2.2.0-py313-torch2.10.0-cu130`
- `cupy-cuda13x-v13.6.0-py314-torch2.10.0-cu130`

## Release Title Format

```
{Package} v{version} Wheel for Python {3.13|3.14} + PyTorch {version} + CUDA 13.0
```

Example:
- `SageAttention v2.2.0 Wheel for Python 3.13 + PyTorch 2.10.0 + CUDA 13.0`

## Triggering Builds

### Manual Trigger
```bash
# Python 3.13
gh workflow run build-nunchaku-py313.yml
gh workflow run build-sageattention-py313.yml
gh workflow run build-flash-attention-py313.yml
gh workflow run build-cupy-cuda13x-py313.yml

# Python 3.14
gh workflow run build-nunchaku-py314.yml
gh workflow run build-sageattention-py314.yml
gh workflow run build-flash-attention-py314.yml
gh workflow run build-cupy-cuda13x-py314.yml
```

### Schedule
Workflows run weekly on Monday:
- Python 3.13: 00:00 (Nunchaku), 02:00 (Flash), 04:00 (Sage), 06:00 (CuPy)
- Python 3.14: 01:00 (Nunchaku), 03:00 (Flash), 05:00 (Sage), 07:00 (CuPy)

## Build Times

- **Nunchaku**: ~25 minutes
- **SageAttention**: ~9 minutes
- **Flash Attention**: ~5.5 hours (uses 16GB swap to prevent OOM)
- **CuPy-CUDA13x**: ~15-20 minutes (estimated)

## Flash Attention Special Notes

Flash Attention requires special handling:

1. **16GB Swap**: The workflow creates a 16GB swap file to prevent OOM kills during compilation
2. **MAX_JOBS=1**: Only one parallel compilation job to conserve memory
3. **Long Build Time**: Takes 5-6 hours due to swap usage (vs ~50min with sufficient RAM)
4. **Disk Cleanup**: Aggressive cleanup to free ~80GB for compilation

The swap configuration is in the workflow:
```yaml
- name: Set up swap space
  run: |
    sudo fallocate -l 16G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
```

## CuPy Special Notes

CuPy has different version requirements for different Python versions:

1. **Python 3.13**: Uses CuPy v13.6.0 (stable)
2. **Python 3.14**: Uses CuPy v14.0.0rc1 (release candidate)
   - Python 3.14 support was added in CuPy v14
   - As of February 2026, v14 stable is not yet released, so we use v14.0.0rc1
   - Update to stable v14.0.0 when available

**Important**: CuPy v13.x does NOT support Python 3.14. The py314 workflow will fail if you try to build v13.6.0.

## Version Metadata in Wheels

- **Nunchaku**: `nunchaku-1.0.2+torch2.10-cp313-cp313-linux_x86_64.whl`
- **SageAttention**: `sageattention-2.2.0+cu130torch2.10.0-cp313-cp313-linux_x86_64.whl`
- **Flash Attention**: `flash_attn-2.8.2-cp313-cp313-linux_x86_64.whl` (no metadata - not patched)
- **CuPy-CUDA13x**: `cupy_cuda13x-13.6.0+cu130sm89-x86_64-cp313-cp313-linux_x86_64.whl`

Nunchaku, SageAttention, and CuPy have version injection patches in their workflows that add CUDA version and/or architecture metadata:
- Nunchaku: `+cu130torch2.10.0`
- SageAttention: `+cu130torch2.10.0`
- CuPy: `+cu130sm89-x86_64` (CUDA 13.0 + SM 8.9 GPU arch + x86_64 system arch)

## Updating Package Versions

To build a new version of a package:

1. Trigger the workflow with custom version input:
```bash
gh workflow run build-nunchaku-py313.yml -f nunchaku_version=1.0.3 -f pytorch_version=2.10.0
```

2. Or update the default version in the workflow file's `inputs` section

## Repository Settings

**CRITICAL**: Workflow permissions must be set to `write`:
```bash
gh api -X PUT repos/retif/pytorch-wheels-builder/actions/permissions/workflow -f default_workflow_permissions=write
```

Without this, release creation will fail with HTTP 403 errors.

## Common Tasks

### Delete Old Releases with Wrong Tags
```bash
gh release delete nunchaku-v1.0.2-py313-cu130 --yes  # Old format
# Then rebuild with correct tag format
gh workflow run build-nunchaku-py313.yml
```

### Check Build Status
```bash
gh run list --limit 5
gh run view <run-id> --log
```

### Update README with New Versions
After adding new package versions, update:
- Download URLs in the "Install from GitHub Releases" section
- Version numbers in examples
- Build configuration if Python/CUDA/PyTorch versions change

## Python Versions

- **Python 3.13**: 3.13.11
- **Python 3.14**: 3.14.2

These are set by `actions/setup-python` and may auto-update to patch releases.

## Build Configuration

All workflows use:
- **CUDA**: 13.0.88 (manually installed from NVIDIA repos)
- **PyTorch**: 2.10.0+cu130
- **CUDA Arch**: 8.9 (RTX 4090 / Ada Lovelace)
- **Compilers**: GCC/G++ 11.4.0
- **Runner**: ubuntu-latest (Ubuntu 22.04)

## Adding a New Package

1. Create workflow files (copy existing and modify):
   - `.github/workflows/build-{package}.yml` (Python 3.13)
   - `.github/workflows/build-{package}-py314.yml` (Python 3.14)

2. Update workflow:
   - Package repository URL
   - Version defaults
   - Build command
   - Test command (if applicable)
   - Schedule time (avoid conflicts)

3. Add version injection patch if needed (see Nunchaku/SageAttention examples)

4. Update README.md with new package

## Troubleshooting

### Build Fails with "No SM targets found"
The package's setup.py is trying to auto-detect GPU architecture but the runner has no GPU. Add a patch to force `TORCH_CUDA_ARCH_LIST`:

```yaml
- name: Patch setup.py for cross-compilation
  run: |
    sed -i '/assert.*sm_targets/d' setup.py
```

### Build Fails with OOM (exit code 143)
Add swap space and reduce MAX_JOBS (see Flash Attention workflow).

### Release Creation Fails with HTTP 403
Check repository workflow permissions (see Repository Settings above).

### Wheel Doesn't Have Version Metadata
Add version injection patch to the workflow (see Nunchaku workflow for example).

## GitHub Actions Permissions

Workflows need:
- `contents: write` - to create releases
- Default workflow permissions: `write` - repository setting

## Links

- **Repository**: https://github.com/retif/pytorch-wheels-builder
- **Releases**: https://github.com/retif/pytorch-wheels-builder/releases
- **Nunchaku**: https://github.com/nunchaku-tech/nunchaku
- **Flash Attention**: https://github.com/Dao-AILab/flash-attention
- **SageAttention**: https://github.com/thu-ml/SageAttention
- **CuPy**: https://github.com/cupy/cupy
