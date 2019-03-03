#!/bin/bash
set -e
gsutil cp ${script_path} /tmp/startup.sh
nohup /bin/bash /tmp/startup.sh >/tmp/startup.log 2>&1 &
exit 0