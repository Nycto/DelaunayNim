#
# Functions for interacting with points
#

import algorithm
import sets


# A type interface for dealing with points
type
    Point* = generic p
        p.x is float
        p.y is float


# Creates a point
proc pnt*( x, y: float ): tuple[x, y: float] =
    result = (x, y)


# A list of sorted, unique points
type
    PointList*[T] = distinct seq[T]


# Creates a point list from a list of points
proc newPointList*[T: Point]( list: openArray[T] ): PointList[T] =

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


# Convert a Point list back to a sequence
proc `@`*[T]( points: PointList[T] ): seq[T] = seq[T](points)



