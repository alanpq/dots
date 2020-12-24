#!/usr/bin/env python3

from gi.repository import Playerctl, GLib
from subprocess import Popen
from urllib.request import urlretrieve
from random import random

player = Playerctl.Player()
lastTrackName = ""

def on_track_change(player, e):
    trackName = player.get_title()
    if trackName == globals()["lastTrackName"]: return
    globals()["lastTrackName"] = trackName

    track_info = '{artist} - {title}'.format(artist=player.get_artist(), title=trackName)
    print(e['mpris:artUrl'])
    path = "/tmp/" + str(int(random() * 1000)) + ".jpeg"
    print(path)
    urlretrieve(e['mpris:artUrl'], path)
    Popen(['dunstify', track_info, "-r", "12345" "-i", path])

player.on('metadata', on_track_change)

GLib.MainLoop().run()

