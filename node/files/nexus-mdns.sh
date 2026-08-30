#!/bin/sh

set -e

local_ip="$(ip --json route | jq -r '.[] | select(.dst == "default") | .prefsrc')"
avahi-publish -R -a mgmt.local $local_ip
