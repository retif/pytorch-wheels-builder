# PyTorch Wheels Builder - Project Summary

## 🎯 Purpose

Build custom binary wheels for Python 3.13 + CUDA 13.0:
- **Nunchaku** - High-performance inference optimization
- **Flash Attention** - Fast and memory-efficient attention
- **SageAttention** - Optimized attention mechanism

## 📁 Project Structure

```
pytorch-wheels-builder/
├── .github/workflows/
│   ├── build-nunchaku.yml           # Build Nunchaku wheel
│   ├── build-flash-attention.yml    # Build Flash Attention wheel
│   ├── build-sageattention.yml      # Build SageAttention wheel
│   └── build-all.yml                # Trigger all builds
├── deploy.sh                        # Deployment script
├── README.md                        # Main documentation
├── SETUP.md                         # Setup instructions
├── PROJECT_SUMMARY.md              # This file
└── .gitignore                       # Git ignore rules
```

## 🚀 Quick Deploy

```bash
cd /home/oleks/projects/pytorch-wheels-builder
./deploy.sh
```

This will:
1. Create GitHub repository `retif/pytorch-wheels-builder`
2. Push all files to main branch
3. Make workflows available in Actions tab

## 🔧 GitHub Actions Workflows

### Individual Workflows

| Workflow | Schedule | Trigger |
|----------|----------|---------|
| Build Nunchaku | Mon 00:00 UTC | Manual + Weekly |
| Build Flash Attention | Mon 02:00 UTC | Manual + Weekly |
| Build SageAttention | Mon 04:00 UTC | Manual + Weekly |
| Build All | 1st of month | Manual + Monthly |

### Build Configuration

- **Python**: 3.13
- **CUDA**: 13.0
- **PyTorch**: 2.10.0+cu130
- **CUDA Arch**: 8.9 (RTX 4090)
- **Runner**: ubuntu-latest (free tier)

## 📦 Using the Wheels

### In ComfyUI Dockerfile

Update `/home/oleks/projects/ComfyUI-Docker/cu130-megapak-pt210/Dockerfile`:

Replace line 248-251 (commented out section) with:

```dockerfile
# Performance optimization libraries
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -U uv \
    # Nunchaku (binary pair with PyTorch)
    && pip install \
https://github.com/retif/pytorch-wheels-builder/releases/download/nunchaku-v1.0.2-py313-cu130/nunchaku-1.0.2+torch2.10-cp313-cp313-linux_x86_64.whl \
    # FlashAttention (binary pair with PyTorch & CUDA)
    && pip install \
https://github.com/retif/pytorch-wheels-builder/releases/download/flash-attn-v2.8.2-py313-cu130/flash_attn-2.8.2+cu130torch2.10-cp313-cp313-linux_x86_64.whl \
    # SageAttention
    && pip install \
https://github.com/retif/pytorch-wheels-builder/releases/download/sageattention-v2.2.0-py313-cu130/sageattention-2.2.0-cp313-cp313-linux_x86_64.whl
```

### Direct Installation

```bash
# Nunchaku
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/nunchaku-v1.0.2-py313-cu130/nunchaku-1.0.2+torch2.10-cp313-cp313-linux_x86_64.whl

# Flash Attention
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/flash-attn-v2.8.2-py313-cu130/flash_attn-2.8.2+cu130torch2.10-cp313-cp313-linux_x86_64.whl

# SageAttention
pip install https://github.com/retif/pytorch-wheels-builder/releases/download/sageattention-v2.2.0-py313-cu130/sageattention-2.2.0-cp313-cp313-linux_x86_64.whl
```

## 🔄 Build Process

```
Trigger (Manual/Schedule)
         ↓
GitHub Actions Runner (ubuntu-latest)
         ↓
Install Python 3.13
         ↓
Install CUDA 13.0 Toolkit
         ↓
Install PyTorch 2.10.0+cu130
         ↓
Clone Source Repository
         ↓
Build Wheel (setup.py bdist_wheel)
         ↓
Test Wheel (import check)
         ↓
Create GitHub Release
         ↓
Upload Wheel Artifact
```

## 📊 Expected Results

After successful builds, you'll have:

### Releases

- `nunchaku-v1.0.2-py313-cu130`
- `flash-attn-v2.8.2-py313-cu130`
- `sageattention-v2.2.0-py313-cu130`

### Artifacts

Each release includes:
- `.whl` file (binary wheel)
- Build metadata
- Installation instructions

## 🎯 Integration with ComfyUI

Once wheels are built:

1. **Update ComfyUI Dockerfile** with wheel URLs
2. **Rebuild ComfyUI image**:
   ```bash
   cd /home/oleks/projects/ComfyUI-Docker
   gh workflow run build-cu130-megapak-pt210.yml --repo retif/ComfyUI-Docker
   ```
3. **Redeploy to Kubernetes**:
   ```bash
   cd /home/oleks/projects/helms/comfyui-vanilla
   helm upgrade comfyui-megapak-test . -f values-megapak-test.yaml -n howard-comfyui
   ```
4. **Verify** in ComfyUI logs:
   ```
   ✅ Nunchaku loaded
   ✅ Flash Attention available
   ✅ SageAttention available
   ```

## 💡 Benefits

### Performance
- **Nunchaku**: Up to 2x faster inference
- **Flash Attention**: 2-4x faster attention, 10-20x less memory
- **SageAttention**: Improved throughput, reduced memory

### Automation
- **Weekly builds**: Always up-to-date with latest versions
- **Zero maintenance**: Automated testing and releases
- **Free hosting**: GitHub Actions + Releases

## 🔍 Monitoring

Check build status:
```bash
# List recent builds
gh run list --repo retif/pytorch-wheels-builder --limit 10

# Watch specific build
gh run watch <run-id> --repo retif/pytorch-wheels-builder

# View logs
gh run view <run-id> --log --repo retif/pytorch-wheels-builder
```

## 🛠️ Troubleshooting

### Build Fails

1. Check CUDA toolkit installation
2. Verify PyTorch version compatibility
3. Check source repository tags/versions

### Wheel Installation Fails

1. Ensure PyTorch 2.10.0+cu130 is installed first
2. Verify CUDA 13.0 runtime available
3. Check Python version: `python --version` (should be 3.13.x)

### Missing Dependencies

If builds need additional dependencies, update workflow files:
```yaml
- name: Install build dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y <package-name>
```

## 📈 Future Enhancements

Potential improvements:
- [ ] Multi-architecture support (7.5, 8.0, 8.6, 8.9, 9.0)
- [ ] Multiple Python versions (3.11, 3.12, 3.13)
- [ ] Build matrix for different combinations
- [ ] Automated version detection from source repos
- [ ] Notification on build completion (Slack, email)

## 📞 Support

- **GitHub Issues**: https://github.com/retif/pytorch-wheels-builder/issues
- **Actions**: https://github.com/retif/pytorch-wheels-builder/actions
- **Releases**: https://github.com/retif/pytorch-wheels-builder/releases

## 📝 License

This repository contains build scripts only. See individual projects for licenses:
- [Nunchaku](https://github.com/nunchaku-tech/nunchaku/blob/main/LICENSE)
- [Flash Attention](https://github.com/Dao-AILab/flash-attention/blob/main/LICENSE)
- [SageAttention](https://github.com/thu-ml/SageAttention/blob/main/LICENSE)
