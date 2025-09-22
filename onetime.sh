#!/bin/bash
# =============================================
# One-time setup for git_push
# Author: karc46
# =============================================

echo "🛠️  Git One-Time Setup Script"
echo "=============================="

# 1️⃣ Set global Git config
echo "📝 Setting up Git configuration..."
read -rp "Enter your Git username [karc46]: " GIT_USER
GIT_USER=${GIT_USER:-ex:karthi46}

read -rp "Enter your Git email [karthikeyan021199@gmail.com]: " GIT_EMAIL
GIT_EMAIL=${GIT_EMAIL:-karthixxxx@gmail.com}

git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

echo "✅ Git config set:"
git config --global user.name
git config --global user.email
echo ""

# 2️⃣ Generate SSH key if not exists
if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
    echo "🔑 Generating SSH key for GitHub..."
    ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key generated at ~/.ssh/id_rsa.pub"
    echo ""
    echo "📋 Please add this SSH key to your GitHub account:"
    cat ~/.ssh/id_rsa.pub
    echo ""
    read -p "Press Enter after adding the SSH key to GitHub..."
fi

# 3️⃣ Ask for local Git repository path
echo "📁 Setting up repository..."
read -rp "Enter your local Git repository path: " REPO_PATH

# Check if directory exists
if [[ ! -d "$REPO_PATH" ]]; then
    echo "❌ Directory '$REPO_PATH' does not exist."
    exit 1
fi

# Initialize git if not already a repository
if [[ ! -d "$REPO_PATH/.git" ]]; then
    echo "📦 Initializing new Git repository..."
    cd "$REPO_PATH" || exit 1
    git init
    git branch -M main  # Use 'main' instead of 'master'
    echo "✅ New Git repository initialized"
else
    echo "✅ Existing Git repository found"
fi

# 4️⃣ Fix ownership and permissions
echo "🔧 Fixing ownership and permissions..."
sudo chown -R $USER:$USER "$REPO_PATH" 2>/dev/null
chmod -R u+rwX "$REPO_PATH"
echo "✅ Permissions fixed."

# 5️⃣ Copy git_push script to /usr/local/bin/
echo "📋 Installing git_push script..."
GIT_PUSH_SRC=""
if [[ -f "./git_push" ]]; then
    GIT_PUSH_SRC="./git_push"
elif [[ -f "/usr/local/bin/git_push" ]]; then
    GIT_PUSH_SRC="/usr/local/bin/git_push"
else
    read -rp "Enter full path of your git_push script: " GIT_PUSH_SRC
fi

if [[ ! -f "$GIT_PUSH_SRC" ]]; then
    echo "❌ git_push script not found at '$GIT_PUSH_SRC'"
    exit 1
fi

sudo cp "$GIT_PUSH_SRC" /usr/local/bin/git_push
sudo chmod +x /usr/local/bin/git_push
echo "✅ git_push installed at /usr/local/bin/git_push"

# 6️⃣ Update the script's WORK_DIR to point to the user's repository
echo "🔄 Updating git_push script with your repository path..."
sudo sed -i "s|WORK_DIR=\".*\"|WORK_DIR=\"$REPO_PATH\"|" /usr/local/bin/git_push

# 7️⃣ Test SSH connection to GitHub
echo "🔗 Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH connection to GitHub successful!"
else
    echo "⚠️  SSH connection test failed. Please check your SSH key setup."
fi

echo ""
echo "🎉 One-time setup complete!"
echo "============================"
echo "You can now run:"
echo "   git_push <file_or_folder>"
echo ""
echo "Example:"
echo "   git_push ~/Documents/my_project"
echo ""
echo "To verify setup:"
echo "   git_push --help"
