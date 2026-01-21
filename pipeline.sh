#!/usr/bin/env bash
set -euo pipefail

bash collect.sh
bash convert.sh
bash generate.sh
