#!/bin/bash

set -ex

export KUBECONFIG=/home/engineer/.kube/config
source /labmachine/env.sh
source "/labmachine/startup/_common.sh"

echo "🔁 starting custom init script" >> /labmachine/logs/userinfo.log

# script used for custom init commands for labmachines for this course

# load nvm to install nodejs packages
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# load brew to install packages
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export HOMEBREW_NO_INSTALL_CLEANUP=1

# Configure CRM application environment variables
echo "🔧 Configuring CRM application environment variables"

# wait for gitlab-git to run
( 
  # Update VITE_API_URL in frontend/.env
  sed -i "s|VITE_API_URL=.*|VITE_API_URL=$(lab_url backend 8000)|" "$CI_PROJECT_DIR/crm-fastapi-react/frontend/.env"

  # Replace https://*.letskube.com in BACKEND_CORS_ORIGINS with frontend URL
  sed -i "s|https://[^,]*\.letskube\.com|$(lab_url frontend 5173)|g" "$CI_PROJECT_DIR/crm-fastapi-react/.env"

  # wait for git to be ready, then commit and push the change
  retry -c 600 -i 1s -- ls /labmachine/status/gitlab-git
  git add "$CI_PROJECT_DIR/crm-fastapi-react/.env" "$CI_PROJECT_DIR/crm-fastapi-react/frontend/.env"
  git commit -m "crm-fastapi-react startup labmachine url customisation"
  git push
)&

# pull n8n image to improve n8n exercise time
docker pull n8nio/n8n:1.116.2

# wait for docker and then heat up the crm-fastapi-react app
( 
  retry -c 600 -i 1s -- ls /labmachine/status/docker

  cd $CI_PROJECT_DIR/crm-fastapi-react
  docker compose build ||echo "may error but still works"
  docker compose pull ||echo "may error but still works"

)&

# install dependencies for frontend
(
  # install npm dependencies
  cd $CI_PROJECT_DIR/crm-fastapi-react/frontend 
  npm install
)&

# install dependencies for backend
(
  # wait for uv to be installed
  retry -c 600 -i 1s -- uv --version

  # install python dependencies and make them load as default
  cd $CI_PROJECT_DIR/crm-fastapi-react
  source scripts/setup_python_env.sh
  echo "source $CI_PROJECT_DIR/crm-fastapi-react/backend/.venv/bin/activate" >> ~/.bashrc_labmachine
)&

# install claude code
( 
  tar -xvf .labmachine/claude.tar.gz -C /
  cat $LAB_CLAUDE_AUTH > ~/.claude.json
  npm install -g @anthropic-ai/claude-code
)

# Add aider configuration to bashrc_labmachine
cat >> ~/.bashrc_labmachine << 'EOF'
export AIDER_API_KEY="openrouter=$LAB_OPENROUTER_TOKEN"
export AIDER_MODEL="openrouter/anthropic/claude-sonnet-4"
export AIDER_GITIGNORE="false"
export AIDER_CHECK_UPDATE="false"
EOF

# install brew packages
brew install pipx aider uv glab &

# aider warmup
/home/linuxbrew/.linuxbrew/bin/aider --model openrouter/google/gemini-2.5-flash --yes --message "create file aider-test.txt" &

# uninstall some extensions: (Will be solved by explicit installs per course)
code-server --uninstall-extension hashicorp.terraform ||true
code-server --uninstall-extension redhat.ansible ||true
code-server --uninstall-extension hashicorp.terraform ||true

# install github copilot
code-server --force --install-extension $CI_PROJECT_DIR/.labmachine/github.copilot-1.372.0.vsix ||echo "github copilot install failed"
code-server --force --install-extension $CI_PROJECT_DIR/.labmachine/github.copilot-chat-0.31.2.vsix ||echo "github copilot chat install failed"
code --force --install-extension $CI_PROJECT_DIR/.labmachine/github.copilot-1.372.0.vsix ||echo "github copilot install failed"
code --force --install-extension $CI_PROJECT_DIR/.labmachine/github.copilot-chat-0.31.2.vsix ||echo "github copilot chat install failed"

# installing claude desktop (does not work on Hetzner due to IP blocking)
# https://github.com/aaddrick/claude-desktop-debian
# wget https://github.com/joshuacox/claude-desktop-appimage/releases/download/v0.11.3/claude-desktop_0.11.3_amd64.deb
# sudo dpkg -i claude-desktop_0.11.3_amd64.deb
# sudo apt --fix-broken install 

# # Start aider-chat install in the background
# (
#   python3 -m pip install aider-chat
# ) &

# # Install homebrew packages
# brew tap gofireflyio/aiac https://github.com/gofireflyio/aiac
# brew install aichat lazygit llm aider &

# # Install lastminute packages
# (sudo apt update && sudo apt install fzf) &
# curl -L https://github.com/danielmiessler/fabric/releases/latest/download/fabric-linux-amd64 > /tmp/fabric && chmod +x /tmp/fabric && sudo mv /tmp/fabric /usr/local/bin

# Wait for everything to finish
wait 

# Authenticate with GitLab
glab auth login -t "$LAB_GITLAB_TOKEN" -h gitlab.letsboot.com || true

# persist prometheus login vars
lab_persist_vars

lab_userinfo "started custom init script"; touch /labmachine/status/custom-init
