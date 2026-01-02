#!/bin/bash
set -e

mkdir -p public/ko
LANG=ko npx quartz build -o public/ko
