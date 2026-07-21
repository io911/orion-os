#!/usr/bin/env bash
set -euo pipefail

# Ensure the greeter user owns the greetd configuration directories
mkdir -p /var/lib/greetd
chown -R greeter:greeter /etc/greetd /var/lib/greetd
chmod 755 /etc/greetd
