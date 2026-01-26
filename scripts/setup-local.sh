#!/bin/bash

# CRM Training Application - Local Setup Script
# This script sets up the application for local development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  CRM Training App - Local Setup${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check Python version
echo -e "${YELLOW}Checking Python version...${NC}"
PYTHON_VERSION=$(python3 --version 2>/dev/null | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
if [ -z "$PYTHON_VERSION" ]; then
    echo -e "${RED}Error: Python is not installed${NC}"
    echo "Please install Python 3.11 or higher"
    exit 1
fi

PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d '.' -f 1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d '.' -f 2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]); then
    echo -e "${RED}Error: Python 3.11 or higher is required (found: $PYTHON_VERSION)${NC}"
    exit 1
fi
echo -e "${GREEN}Python version $PYTHON_VERSION found${NC}"

# Check for uv
echo -e "${YELLOW}Checking for uv...${NC}"
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}uv not found, installing...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env
fi
echo -e "${GREEN}uv found${NC}"

# Check Node.js
echo -e "${YELLOW}Checking Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed${NC}"
    echo "Please install Node.js 18 or higher"
    exit 1
fi
NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}Error: Node.js 18 or higher is required${NC}"
    exit 1
fi
echo -e "${GREEN}Node.js $(node -v) found${NC}"

# Install backend dependencies
echo ""
echo -e "${YELLOW}Installing backend dependencies...${NC}"
cd backend
uv sync
cd ..

# Install frontend dependencies
echo ""
echo -e "${YELLOW}Installing frontend dependencies...${NC}"
cd frontend
npm install
cd ..

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "To start the development servers, run these commands in separate terminals:"
echo ""
echo -e "  ${YELLOW}Terminal 1 (Backend):${NC}"
echo -e "    cd backend && uv run uvicorn app.main:app --reload"
echo ""
echo -e "  ${YELLOW}Terminal 2 (Frontend):${NC}"
echo -e "    cd frontend && npm run dev"
echo ""
echo -e "Then open ${GREEN}http://localhost:5173${NC} in your browser"
echo ""
echo -e "API documentation: ${GREEN}http://localhost:8000/docs${NC}"
echo ""
echo -e "Default superuser credentials:"
echo -e "  Email: ${YELLOW}dev@example.com${NC}"
echo -e "  Password: ${YELLOW}DevPassword${NC}"
echo ""
