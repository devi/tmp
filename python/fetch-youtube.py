#!/usr/bin/env python
# -*- coding: utf-8 -*-

import youtube_dl
import json
import sys

class DummyLogger(object):
    def debug(self, msg):
        pass

    def warning(self, msg):
        pass

    def error(self, msg):
        sys.exit("0")

ydl_opts = {
    'logger': DummyLogger(),
    'dump_single_json': True
}

with youtube_dl.YoutubeDL(ydl_opts) as ydl:
   res = ydl.extract_info(
     'http://www.youtube.com/watch?v=BaW_jenozKc',
     download=False
   )

print(json.dumps(res))
