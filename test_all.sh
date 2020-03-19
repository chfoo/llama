#!/bin/bash -x

nodejs out/js/test.js
source <(luarocks path)
lua out/lua/test.lua
neko out/neko/test.n
php out/php/index.php
out/cpp/TestAll-debug
out/cs/bin/TestAll-Debug.exe
(cd out/java && java -jar TestAll-Debug.jar)
python3 out/python/test.py
hl out/hl/test.hl

