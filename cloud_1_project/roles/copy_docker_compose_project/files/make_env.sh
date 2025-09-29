#!/usr/bin/env bash

set -eux

if ! [ -f "${PWD}/wordpress.env" ];then
    echo -e 