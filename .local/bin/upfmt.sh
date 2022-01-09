#!/bin/sh

uptime | awk -F '[ ,:]+' '{if ($7 ~ /^[0-9]+$/) printf "%sh %sm\n", $6,$7; else printf "%sm\n", $6}'
