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
├── build-cupy-cuda13x-py313.yml         # Python 3.13 build
├── build-cupy-cuda13x-py314.yml         # Python 3.14 build (GIL)
├── build-cupy-cuda13x-py314t.yml        # Python 3.14t build (free-threaded)
├── build-opencv-python-py314t-cpu.yml   # Python 3.14t build (free-threaded, CPU-only)
├── build-opencv-python-py314t-cu130.yml # Python 3.14t build (free-threaded, CUDA 13.0)
├── build-opencv-python-py314-cu130.yml  # Python 3.14 build (GIL, CUDA 13.0)
└── build-llvmlite-py314t.yml            # Python 3.14t build (free-threaded)
```

## Release Tag Format

**IMPORTANT**: All releases must use this tag format:
```
# For PyTorch-dependent packages:
{package}-v{version}-py{313|314|314t}-torch{pytorch_version}-cu130

# For CPU-only packages (llvmlite, opencv-python):
{package}-v{version}-py{314t}-llvm{llvm_version}  # llvmlite
{package}-v{version}-py{314t}  # opencv-python
```

Examples:
- `nunchaku-v1.0.2-py313-torch2.10.0-cu130`
- `flash-attn-v2.8.2-py314-torch2.10.0-cu130`
- `sageattention-v2.2.0-py313-torch2.10.0-cu130`
- `cupy-cuda13x-v13.6.0-py314-torch2.10.0-cu130`
- `cupy-cuda13x-v14.0.0rc1-py314t-torch2.10.0-cu130` (free-threaded)
- `opencv-python-v4.11.0.92-py314t` (free-threaded, CPU-only)
- `llvmlite-v0.44.0-py314t-llvm15` (free-threaded, CPU-only)

## Release Title Format

```
# For PyTorch-dependent packages:
{Package} v{version} Wheel for Python {3.13|3.14|3.14t} + PyTorch {version} + CUDA 13.0

# For CPU-only packages:
{Package} v{version} Wheel for Python {3.14t} (Free-threaded) + LLVM {version}  # llvmlite
{Package} v{version} Wheel for Python {3.14t} (Free-threaded)  # opencv-python
```

Examples:
- `SageAttention v2.2.0 Wheel for Python 3.13 + PyTorch 2.10.0 + CUDA 13.0`
- `CuPy-CUDA13x v14.0.0rc1 Wheel for Python 3.14t (Free-threaded) + PyTorch 2.10.0 + CUDA 13.0`
- `OpenCV-Python v4.11.0.92 Wheel for Python 3.14t (Free-threaded)`
- `llvmlite v0.44.0 Wheel for Python 3.14t (Free-threaded) + LLVM 15`

## Triggering Builds

### Manual Trigger
```bash
# Python 3.13
gh workflow run build-nunchaku-py313.yml
gh workflow run build-sageattention-py313.yml
gh workflow run build-flash-attention-py313.yml
gh workflow run build-cupy-cuda13x-py313.yml

# Python 3.14 (GIL)
gh workflow run build-nunchaku-py314.yml
gh workflow run build-sageattention-py314.yml
gh workflow run build-flash-attention-py314.yml
gh workflow run build-cupy-cuda13x-py314.yml

# Python 3.14t (Free-threaded)
gh workflow run build-cupy-cuda13x-py314t.yml
gh workflow run build-opencv-python-py314t-cpu.yml  # CPU-only
gh workflow run build-opencv-python-py314t-cu130.yml  # CUDA 13.0
gh workflow run build-llvmlite-py314t.yml

# Python 3.14 with CUDA 13.0
gh workflow run build-opencv-python-py314-cu130.yml
```

### Schedule
Workflows run weekly on Monday:
- Python 3.13: 00:00 (Nunchaku), 02:00 (Flash), 04:00 (Sage), 06:00 (CuPy)
- Python 3.14 (GIL): 01:00 (Nunchaku), 03:00 (Flash), 05:00 (Sage), 08:00 (CuPy), 11:00 (OpenCV+CUDA)
- Python 3.14t (Free-threaded): 07:00 (CuPy), 09:00 (OpenCV CPU), 10:00 (llvmlite), 12:00 (OpenCV+CUDA)

## Build Times

- **Nunchaku**: ~25 minutes
- **SageAttention**: ~9 minutes
- **Flash Attention**: ~5.5 hours (uses 16GB swap to prevent OOM)
- **CuPy-CUDA13x**: ~15-20 minutes
- **OpenCV-Python**: ~30-45 minutes (estimated)
- **llvmlite**: ~10-15 minutes (estimated)

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
2. **Python 3.14 (GIL)**: Uses CuPy v14.0.0rc1 (release candidate)
   - Python 3.14 support was added in CuPy v14
   - As of February 2026, v14 stable is not yet released, so we use v14.0.0rc1
   - Update to stable v14.0.0 when available
3. **Python 3.14t (Free-threaded)**: Uses CuPy v14.0.0rc1 (release candidate)
   - Builds without fastrlock due to Cython compatibility issues with GIL-free Python
   - See TODO in workflow to re-enable fastrlock when cp314t support is available

**Important**: CuPy v13.x does NOT support Python 3.14. The py314 workflow will fail if you try to build v13.6.0.

## OpenCV-Python Special Notes

OpenCV-Python has **three** separate workflows:

### 1. CPU-Only Build (Python 3.14t Free-threaded)
- **Workflow**: `build-opencv-python-py314t-cpu.yml`
- **Release tag**: `opencv-python-v{version}-py314t-cpu`
- **No PyTorch/CUDA dependency**: CPU-only for simplicity and compatibility
- **Benefits**: Simpler build, faster compilation (~15-20 minutes)
- **Use case**: Free-threaded Python's main benefit is CPU parallelism
- **Status**: ❌ Blocked by upstream ADE library C++ compatibility issue (missing `#include <cstdint>`)
- Built with `-DWITH_CUDA=OFF`

### 2. CUDA Build (Python 3.14t Free-threaded)
- **Workflow**: `build-opencv-python-py314t-cu130.yml`
- **Release tag**: `opencv-python-v{version}-py314t-cu130`
- **Status**: ❌ **CANNOT BUILD** - Two blocking issues:
  1. ADE library C++ compatibility (same as CPU build)
  2. opencv_contrib cudev module incompatible with CUDA 13.0 (deprecated texture APIs)
- Requires opencv_contrib for cudev module

### 3. CUDA Build (Python 3.14 with GIL)
- **Workflow**: `build-opencv-python-py314-cu130.yml`
- **Release tag**: `opencv-python-v{version}-py314-cu130`
- **Status**: ❌ **CANNOT BUILD** - opencv_contrib incompatible with CUDA 13.0
  - opencv_contrib cudev uses deprecated CUDA texture APIs (`texture<>`, `cudaUnbindTexture`, `textureReference`)
  - These APIs were removed in CUDA 12.0+
  - Would need CUDA 11.x or wait for opencv_contrib update
- Requires opencv_contrib for cudev module

### Common Notes
1. **No PyTorch Dependency**: OpenCV doesn't depend on PyTorch
2. **Build System**: Uses scikit-build with CMake
   - Requires system dependencies (GTK, video codecs, etc.)
3. **Python 3.14 Compatibility**: Standard Python 3.14 (GIL) has better C++ library compatibility than free-threaded
4. **Upstream Issues**:
   - **ADE Library**: Free-threaded builds blocked by missing `#include <cstdint>` in ADE library
   - **CUDA 13.0**: opencv_contrib cudev uses deprecated texture APIs removed in CUDA 12.0+
     - Errors: `texture is not a template`, `cudaUnbindTexture is undefined`, `textureReference is undefined`
     - Cannot build ANY opencv-python wheels with CUDA 13.0
     - Would need CUDA 11.x or updated opencv_contrib
5. **C++17 Requirement for CUDA**: Must set `-DCMAKE_CXX_STANDARD=17 -DCMAKE_CUDA_STANDARD=17 -DCUDA_NVCC_FLAGS=--std=c++17`

## llvmlite Special Notes

llvmlite is different from the other packages:

1. **CPU-Only Package**: llvmlite is a lightweight LLVM Python binding for JIT compilation
   - Release tags use format: `llvmlite-v{version}-py314t-llvm{version}` (no CUDA/PyTorch)
   - Required by Numba and other JIT compilation frameworks
2. **LLVM Dependency**: Requires LLVM development libraries
   - Currently uses LLVM 15 (required for llvmlite 0.44.0+)
   - Version metadata: `+llvm15` injected into wheel version
3. **Python 3.14t Compatibility**: Special patches required for free-threaded Python
   - Patches `spawn(dry_run=...)` calls (Python 3.14 removed dry_run parameter)
   - Standard Python 3.13/3.14 wheels are available from PyPI
   - Free-threaded builds are needed for Numba compatibility
4. **Build System**: Uses setuptools with custom build extensions
   - Fast build (~10-15 minutes)
   - No GPU or heavy compilation required

## Version Metadata in Wheels

- **Nunchaku**: `nunchaku-1.0.2+cu130sm89torch2.10.0-cp313-cp313-linux_x86_64.whl`
- **SageAttention**: `sageattention-2.2.0+cu130sm89torch2.10.0-cp313-cp313-linux_x86_64.whl`
- **Flash Attention**: `flash_attn-2.8.2-cp313-cp313-linux_x86_64.whl` (no metadata - not patched)
- **CuPy-CUDA13x**: `cupy_cuda13x-13.6.0+cu130sm89-cp313-cp313-linux_x86_64.whl`
- **CuPy-CUDA13x (py314t)**: `cupy_cuda13x-14.0.0rc1+cu130sm89-cp314t-cp314t-linux_x86_64.whl`
- **OpenCV-Python (py314t CPU)**: `opencv_python-4.11.0.92-cp314t-cp314t-linux_x86_64.whl` (no version metadata)
- **OpenCV-Python (py314t CUDA)**: `opencv_python-4.11.0.92+cu130sm89-cp314t-cp314t-linux_x86_64.whl`
- **OpenCV-Python (py314 CUDA)**: `opencv_python-4.11.0.92+cu130sm89-cp314-cp314-linux_x86_64.whl`
- **llvmlite (py314t)**: `llvmlite-0.44.0+llvm15-cp314t-cp314t-linux_x86_64.whl`

Nunchaku, SageAttention, CuPy, OpenCV-Python, and llvmlite have version injection patches in their workflows that add comprehensive metadata:
- **Format**: `+cu{CUDA_VER}sm{GPU_ARCH}torch{PYTORCH_VER}` (for PyTorch-dependent packages)
- **Format**: `+cu{CUDA_VER}sm{GPU_ARCH}` (for CuPy and OpenCV-Python)
- **Format**: `+llvm{LLVM_VER}` (for llvmlite)
- **Example**: `+cu130sm89torch2.10.0`
  - `cu130` = CUDA 13.0
  - `sm89` = SM 8.9 GPU architecture (RTX 4090)
  - `torch2.10.0` = PyTorch version (if applicable)
- **Example**: `+llvm15` = LLVM 15
- **Note**: System architecture (x86_64) is automatically included in the platform tag at the end of the wheel name
- **Free-threaded Python**: Wheels use `cp314t` tag instead of `cp314` to indicate GIL-free Python

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
- **Python 3.14** (GIL): 3.14.2
- **Python 3.14t** (Free-threaded): 3.14.x (free-threaded build without GIL)

These are set by `actions/setup-python` and may auto-update to patch releases.

**Free-threaded Python (3.14t)**: Experimental Python build with the GIL removed (PEP 703). Requires special builds of all C extensions. Wheels built for cp314t are NOT compatible with standard cp314.

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
- **OpenCV-Python**: https://github.com/opencv/opencv-python
- **llvmlite**: https://github.com/numba/llvmlite
