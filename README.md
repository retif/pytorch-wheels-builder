# PyTorch Wheels Builder

Custom binary wheels for Python 3.13 + CUDA 13.0

This repository contains GitHub Actions workflows to build optimized binary wheels for:
- **Nunchaku**: High-performance inference optimization
- **Flash Attention**: Fast and memory-efficient attention implementation
- **SageAttention**: Optimized attention mechanism

## GPU Optimization

These wheels are compiled with **CUDA Compute Capability 8.9**, optimized for:
- **NVIDIA Ada Lovelace GPUs** (RTX 40-series: RTX 4090, 4080, 4070, 4060, etc.)
- **Professional Ada GPUs** (RTX 6000 Ada Generation, etc.)

> **Note**: Wheels will work best on GPUs with compute capability 8.9. For other GPU architectures, you may need to build from source with appropriate `TORCH_CUDA_ARCH_LIST` settings.

## Why This Exists

As of February 2026, official binary wheels for Python 3.13 + CUDA 13.0 are not available for these packages. This repository builds them from source using GitHub Actions with CUDA 13.0 toolkit installed.

## Structure

```
.
├── .github/workflows/
│   ├── build-nunchaku.yml
│   ├── build-flash-attention.yml
│   └── build-sageattention.yml
├── builders/
│   ├── nunchaku/
│   ├── flash-attention/
│   └── sageattention/
└── README.md
```

## Built Wheels

Wheels are published as GitHub Releases with tags:
- `nunchaku-v{version}-py313-cu130`
- `flash-attn-v{version}-py313-cu130`
- `sageattention-v{version}-py313-cu130`

## Usage

### Install from GitHub Releases

```bash
# Nunchaku
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/nunchaku-v1.0.2-py313-cu130/nunchaku-1.0.2+torch2.10-cp313-cp313-linux_x86_64.whl

# Flash Attention
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/flash-attn-v2.8.2-py313-cu130/flash_attn-2.8.2+cu130torch2.10-cp313-cp313-linux_x86_64.whl

# SageAttention
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/sageattention-v2.2.0-py313-cu130/sageattention-2.2.0-cp313-cp313-linux_x86_64.whl
```

### Build Configuration

- **Python**: 3.13.11
- **CUDA**: 13.0.88 toolkit
- **PyTorch**: 2.10.0+cu130
- **CUDA Compute Capability**: 8.9 (Ada Lovelace)
- **Compilers**:
  - **GCC**: 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
  - **G++**: 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
- **Build Tools**: CMake 3.22+, Ninja
- **Runner**: ubuntu-latest (Ubuntu 22.04 LTS)

To build for different GPU architectures, modify `TORCH_CUDA_ARCH_LIST` in the workflow files.

## GitHub Actions Setup

The workflows use:
- **ubuntu-latest** with CUDA toolkit installed
- **Python 3.13** from actions/setup-python
- **cibuildwheel** for building manylinux wheels

## Triggers

Workflows can be triggered:
- **Manually**: Via workflow_dispatch
- **On Schedule**: Weekly builds to stay up-to-date
- **On Push**: When source versions are updated

## License

This repository only contains build scripts. See individual projects for their licenses:
- [Nunchaku](https://github.com/nunchaku-tech/nunchaku)
- [Flash Attention](https://github.com/Dao-AILab/flash-attention)
- [SageAttention](https://github.com/thu-ml/SageAttention)
