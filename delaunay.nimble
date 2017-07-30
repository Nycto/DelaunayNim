# Package

version       = "0.3.0"
author        = "Nycto"
description   = "Delaunay triangulator"
license       = "MIT"
skipDirs      = @["test", ".build", "bin"]

# Deps
requires "nim >= 0.17.0"

exec "test -d .build/ExtraNimble || git clone https://github.com/Nycto/ExtraNimble.git .build/ExtraNimble"
when existsDir(thisDir() & "/.build"):
    include ".build/ExtraNimble/extranimble.nim"
