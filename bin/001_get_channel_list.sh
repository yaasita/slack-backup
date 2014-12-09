#!/bin/bash
set -e

source conf/token.sh
curl -s "https://slack.com/api/channels.list?token=${API_TOKEN}&pretty=1" > raw/channels_list.txt
