#!/bin/bash
set -e

mkdir -p public/en
LANG=en npx quartz build -o public/en
