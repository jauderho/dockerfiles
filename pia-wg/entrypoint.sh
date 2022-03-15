#!/usr/bin/env bash
set -Eeuo pipefail

# Generate WG config and show QR code
python3 pia-wg/generate-config.py
echo
cat PIA*conf
echo
cat PIA*conf | qrencode -t ansiutf8 
echo

