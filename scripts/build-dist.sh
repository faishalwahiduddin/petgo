#!/bin/bash
# Reusable build and distribution structuring script for Cloudflare Pages deployment.
set -e

echo "Starting build for GarageGo..."

# 1. Build Flutter Web application inside /app subpath
flutter build web --release --base-href "/app/"

# 2. Re-create distribution target directory
rm -rf build/web-dist
mkdir -p build/web-dist/app

# 3. Copy Flutter Web artifacts to distribution subdirectory
cp -R build/web/* build/web-dist/app/

# 4. Copy landing page assets to distribution root
cp -R web-landing/* build/web-dist/

# 5. Serve privacy policy at /privacy/ (Play Console URL without .html)
# NOTE: this app has no web/privacy dir (unlike apps/); privacy ships from web-landing/privacy.html
mkdir -p build/web-dist/privacy
cp web-landing/privacy.html build/web-dist/privacy/index.html

echo "Build complete. Created build/web-dist/"
echo "To deploy, execute: wrangler-faishal pages deploy ./build/web-dist --project-name garagego-faishal --branch main"
