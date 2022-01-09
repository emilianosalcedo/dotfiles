#!/bin/sh

apt list --upgradable 2>/dev/null | grep -v -i "listando" | wc -l
