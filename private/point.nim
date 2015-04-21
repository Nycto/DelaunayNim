#
# Functions for interacting with points
#

import algorithm
import sets

#
# Points represent simple x,y coordinates. The goal is to allow library
# consumers to use their own objects as points, hence implement them as
# generic type classes
#

type Point* = generic p
    ## A type interface for dealing with points
    p.x is float
    p.y is float

proc pnt*( x, y: float ): tuple[x, y: float] =
    ## Creates a point
    result = (x, y)


#
# PointList is a phantom type that guarantees a list of points is unique and
# in sorted order
#

type PointList*[T] = distinct seq[T]
    ## A list of sorted, unique points

proc newPointList*[T: Point]( list: openArray[T] ): PointList[T] =
    ## Creates a point list from a list of points

    var output: seq[T] = @[]

    # Keep track of the points that have been seen
    var seen = initSet[tuple[x, y: float]]()

    # Dedupe, which also copies the input
    for point in items(list):
        let pair = (x: point.x, y: point.y)

        if not seen.contains(pair):
            seen.incl(pair)
            output.add(point)

    # Sort points left to right, bottom to top
    output.sort do (a, b: T) -> int:
        if a.x < b.x:
            return -1
        elif a.x > b.x:
            return 1
        else:
            return cmp(a.y, b.y)

    result = PointList(output)

proc `@`*[T]( points: PointList[T] ): seq[T] =
    ## Convert a Point list back to a sequence
    seq[T](points)




