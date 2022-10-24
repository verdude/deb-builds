#!/usr/bin/env bash

set -e

USERID=${LOCAL_USER_ID:-2222}
useradd -u $USERID -o user
usermod -aG sudo user
exec gosu user "$@"
