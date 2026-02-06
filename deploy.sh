#!/bin/bash
# Deploy PyTorch Wheels Builder to GitHub

set -euo pipefail

REPO_NAME="pytorch-wheels-builder"
GITHUB_USER="${GITHUB_USER:-retif}"

echo "🚀 Deploying PyTorch Wheels Builder"
echo "===================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Please install it first:"
    echo "   https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI authenticated"
echo ""

# Check if repo already exists
if gh repo view "$GITHUB_USER/$REPO_NAME" &> /dev/null; then
    echo "⚠️  Repository $GITHUB_USER/$REPO_NAME already exists"
    read -p "Do you want to push to existing repo? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        exit 1
    fi
else
    echo "📦 Creating repository: $GITHUB_USER/$REPO_NAME"
    gh repo create "$REPO_NAME" \
        --public \
        --description "Custom PyTorch wheels for Python 3.13 + CUDA 13.0" \
        --clone=false
    echo "✅ Repository created"
fi

echo ""
echo "📂 Initializing Git repository..."

# Initialize git if not already
if [ ! -d .git ]; then
    git init
    echo "✅ Git initialized"
else
    echo "✅ Git already initialized"
fi

# Add all files
git add .

# Commit
if git diff-index --quiet HEAD --; then
    echo "⚠️  No changes to commit"
else
    git commit -m "feat: PyTorch wheels builder for Python 3.13 + CUDA 13.0

- Add workflows for Nunchaku, Flash Attention, SageAttention
- Support Python 3.13 + CUDA 13.0
- Automated builds with GitHub Actions
- Weekly scheduled builds to stay up-to-date"
    echo "✅ Changes committed"
fi

# Set main branch
git branch -M main

# Add remote if not exists
if ! git remote get-url origin &> /dev/null; then
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "✅ Remote 'origin' added"
else
    echo "✅ Remote 'origin' already exists"
fi

# Push
echo ""
echo "⬆️  Pushing to GitHub..."
git push -u origin main --force

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔗 Repository: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "🔗 Actions: https://github.com/$GITHUB_USER/$REPO_NAME/actions"
echo ""
echo "📝 Next steps:"
echo "1. Go to Actions tab"
echo "2. Select 'Build All Wheels' workflow"
echo "3. Click 'Run workflow'"
echo "4. Wait for builds to complete (~15-30 min each)"
echo "5. Check Releases for built wheels"
echo ""
echo "Or trigger individual builds:"
echo "  - Build Nunchaku Wheel"
echo "  - Build Flash Attention Wheel"
echo "  - Build SageAttention Wheel"
