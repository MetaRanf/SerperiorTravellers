#!/bin/bash
# Picks first available iPhone simulator UDID, falls back with clear error
set -e
UDID=$(xcrun simctl list devices available -j | python3 -c "
import sys, json
d = json.load(sys.stdin)['devices']
udid = next((u['udid'] for k, v in d.items() if 'iOS' in k for u in v if 'iPhone' in u['name']), None)
if udid is None:
    sys.stderr.write('ERROR: no available iPhone simulator found. Create one in Xcode (Window > Devices and Simulators) or run: xcrun simctl create \"iPhone 15\" \"com.apple.CoreSimulator.SimDeviceType.iPhone-15\"\n')
    sys.exit(1)
print(udid)
")
if [ -z "$UDID" ]; then
  echo "No simulator UDID; aborting." >&2
  exit 1
fi
echo "$UDID"
