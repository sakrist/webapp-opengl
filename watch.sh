#!/usr/bin/env bash

watchexec -w Sources -e .swift -r './build.sh' &
browser-sync start -s -w --ss Bundle --cwd Bundle