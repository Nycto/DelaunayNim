#
# Runs a delaunay triangulation on a set of points
#

import private/point
import private/edge
import private/anglesort
import private/triangle

iterator triangulate*[T: Point]( rawPoints: openArray[T] ): tuple[a, b: T] =
    ## Iterates through the edges formed by running a delaunay triangulation
    ## on a set of points

    let points = newPointList(rawPoints)

    case points.len
    of 0..1:
        discard

    of 2:
        yield (a: points[0], b: points[1])

    of 3:
        let tri = newTriangle(points[0], points[1], points[2])

        yield (a: tri.a, b: tri.b)
        yield (a: tri.b, b: tri.c)

        # If it isn't a triangle, it's a line. And because we can rely on
        # the sort order of a PointList, we know this would be a duplicate
        # edge unless its a triangle
        if tri.isTriangle:
            yield (a: tri.a, b: tri.c)

    else:
        discard




