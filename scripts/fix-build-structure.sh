#!/bin/bash

# Fix locale folder structure created by Quartz
# Move public/en/en/* to public/en/
# Move public/ko/ko/* to public/ko/

echo "🔧 Fixing build structure..."

# Function to fix relative paths in HTML files
fix_paths() {
  local dir=$1
  # Replace ../ with ./ in all HTML files (for CSS/JS references)
  find "$dir" -name "*.html" -type f -exec sed -i 's|href="../|href="./|g' {} \;
  find "$dir" -name "*.html" -type f -exec sed -i 's|src="../|src="./|g' {} \;
  echo "  Fixed relative paths in $dir"
}

# Fix English build
if [ -d "public/en/en" ]; then
  echo "  Moving public/en/en/* to public/en/"
  mv public/en/en/* public/en/
  rm -rf public/en/en
  fix_paths "public/en"
fi

# Fix Korean build
if [ -d "public/ko/ko" ]; then
  echo "  Moving public/ko/ko/* to public/ko/"
  mv public/ko/ko/* public/ko/
  rm -rf public/ko/ko
  fix_paths "public/ko"
fi

echo "✓ Build structure fixed"
