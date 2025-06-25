#!/bin/bash
set -e

echo "[SETUP] Preparing templates..."
bash ./scripts/prepare-templates.sh

echo "[SETUP] All done. You can now run:"
echo "         docker-compose up -d --build"
