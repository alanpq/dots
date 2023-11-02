#!/usr/bin/env bash
rofi -dmenu -p 'Master Password' -password -l 0 | keepassxc --pw-stdin ~/Passwords.kbdx