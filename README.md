DelaunayNim [![Build Status](https://travis-ci.org/Nycto/DelaunayNim.svg?branch=master)](https://travis-ci.org/Nycto/DelaunayNim)
===========

A Nim library for calculating the Delaunay Triangulation of a set of points.
This is accomplished using a divide and conquer algorithm, as described here:

http://www.geom.uiuc.edu/~samuelp/del_project.html

![Delaunay Triangulation](http://nycto.github.io/DelaunayNim/delaunay.svg)


Quick Example
-------------

```nimrod
import delaunay

# Points can be any object with an `x` and `y` field
let points: seq[tuple[x, y: float]] = @[
    (x: 25.0,  y: 183.0),
    (x: 189.0, y: 187.0),
    (x: 34.0,  y: 169.0),
    (x: 149.0, y: 136.0),
    (x: 78.0,  y: 105.0),
]

for edge in triangulate(points):
    echo edge
```

That app outputs the following:

```
(a: (x: 25.0, y: 183.0), b: (x: 34.0, y: 169.0))
(a: (x: 25.0, y: 183.0), b: (x: 189.0, y: 187.0))
(a: (x: 34.0, y: 169.0), b: (x: 78.0, y: 105.0))
(a: (x: 34.0, y: 169.0), b: (x: 149.0, y: 136.0))
(a: (x: 34.0, y: 169.0), b: (x: 189.0, y: 187.0))
(a: (x: 78.0, y: 105.0), b: (x: 149.0, y: 136.0))
(a: (x: 149.0, y: 136.0), b: (x: 189.0, y: 187.0))
```

Full Example
------------

A full example can be found here:
https://github.com/Nycto/DelaunayNim/blob/master/bin/createSvg.nim

That little binary accepts a list of points and outputs an SVG of the
triangulated grid. You can use it like this:

```
seq 100 \
    | awk 'BEGIN { srand(); } { print int(rand() * 500) " " int(rand() * 500) }' \
    | ./bin/createSvg \
    > example.svg
```

License
-------

This library is released under the MIT License, which is pretty spiffy. You
should have received a copy of the MIT License along with this program. If
not, see http://www.opensource.org/licenses/mit-license.php

