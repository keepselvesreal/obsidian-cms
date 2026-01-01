#!/bin/bash

# Fix locale folder structure created by Quartz
# Move public/en/en/* to public/en/
# Move public/ko/ko/* to public/ko/

echo "🔧 Fixing build structure..."

# Fix English build
if [ -d "public/en/en" ]; then
  echo "  Moving public/en/en/* to public/en/"
  mv public/en/en/* public/en/
  rm -rf public/en/en
fi

# Fix Korean build
if [ -d "public/ko/ko" ]; then
  echo "  Moving public/ko/ko/* to public/ko/"
  mv public/ko/ko/* public/ko/
  rm -rf public/ko/ko
fi

# Copy root index.html from ko (default to Korean)
echo "  Creating root index.html"
cp public/ko/index.html public/index.html

echo "✓ Build structure fixed"
