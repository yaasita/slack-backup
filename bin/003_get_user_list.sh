#!/bin/bash
set -e

source conf/token.sh
curl -s "https://slack.com/api/users.list?token=${API_TOKEN}&pretty=1" > raw/user_list.txt
