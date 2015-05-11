#
# Functions for interacting with points
#

import algorithm, sets, math

#
# Points represent simple x,y coordinates. The goal is to allow library
# consumers to use their own objects as points, hence implement them as
# generic type classes
#

type Point* = concept p ## \
    ## A type interface for dealing with points
    p.x is float
    p.y is float

proc pnt*( x, y: float ): tuple[x, y: float] =
    ## Creates a point
    result = (x, y)

proc `<=>`*[T: Point]( a, b: T ): int =
    ## Compares two points, sorting left to right, bottom to top
    if a.x < b.x:
        return -1
    elif a.x > b.x:
        return 1
    else:
        return cmp(a.y, b.y)


#
# PointList is a phantom type that guarantees a list of points is unique and
# in sorted order
#

type PointList*[T] = object ## \
    ## A list of sorted, unique points

    # The sequence that backs this point list. Passed by reference to avoid
    # making copies every time a slice is extracted
    points: seq[T]

    # The starting offset within the backing sequence for this slice
    start: int

    # The number of points in this slice
    length: int

proc newPointList*[T: Point]( list: openArray[T] ): PointList[T] =
    ## Creates a point list from a list of points

    var output: seq[T] = @[]
    setlen(output, list.len)

    # Keep track of the points that have been seen
    var seen = initSet[tuple[x, y: float]]()

    # Dedupe, which also copies the input
    for point in items(list):
        let pair = (x: point.x, y: point.y)

        if not seen.contains(pair):
            # `add(seq)` pushes on to the end of a sequence, meaning our
            # `setlen` below would remove the wrong values. We use assignment
            # instead to avoid that
            output[seen.len] = point
            seen.incl(pair)

    setlen(output, seen.len)
    shallow(output)

    # Sort points left to right, bottom to top
    output.sort(`<=>`)

    result = PointList[T](points: output, start: 0, length: output.len)

proc `@`*[T]( points: PointList[T] ): seq[T] =
    ## Convert a Point list back to a sequence
    result = @[]
    for i in points.start .. <(points.start + points.length):
        result.add( points.points[i] )

proc len*[T]( points: PointList[T] ): int =
    ## Returns the number of points in a point list
    points.length

proc `[]`*[T]( points: PointList[T], i: int ): T {.inline.} =
    ## Returns a specific point at the given offset
    if i >= points.length:
        raise newException(IndexError, "Index is out of bounds")
    points.points[i + points.start]

type CantSplitError* = object of Exception ## \
    ## Thrown when trying to split a list of points that is too small

proc split*[T](
    points: PointList[T]
): tuple[left, right: PointList[T]] =
    ## Divides this PointList evenly in to two smaller lists
    if len(points) < 4:
        raise newException(CantSplitError, "PointList is too small to split")

    let halfway: float = points.len / 2
    let leftLength = toInt(ceil(halfway))
    let rightLength = toInt(floor(halfway))

    let left = PointList[T](
        points: points.points, start: points.start, length: leftLength)
    let right = PointList[T](
        points: points.points, start: leftLength, length: rightLength)

    return (left: left, right: right)


