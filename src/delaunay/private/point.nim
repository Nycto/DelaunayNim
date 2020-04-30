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

proc `<=>`*[T: Point]( a, b: T ): int =
    ## Compares two points, sorting left to right, bottom to top
    if a.x < b.x:
        return -1
    elif a.x > b.x:
        return 1
    else:
        return cmp(a.y, b.y)

proc toStr*[T: Point]( point: T ): string =
    ## Converts an edge to a readable string
    result = "("
    result.add( if floor(point.x) == point.x: $(int(point.x)) else: $point.x )
    result.add(", ")
    result.add( if floor(point.y) == point.y: $(int(point.y)) else: $point.y )
    result.add(")")


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
    var seen = initHashSet[tuple[x, y: float]]()

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

iterator items*[T]( points: PointList[T] ): T =
    ## Iterates over each point in this list
    for i in points.start .. <(points.start + points.length):
        yield points.points[i]

proc `@`*[T]( points: PointList[T] ): seq[T] =
    ## Convert a Point list back to a sequence
    result = @[]
    for point in points:
        result.add(point)

proc len*[T]( points: PointList[T] ): int =
    ## Returns the number of points in a point list
    points.length

proc `[]`*[T]( points: PointList[T], i: int ): T {.inline.} =
    ## Returns a specific point at the given offset
    if i >= points.length:
        raise newException(IndexError, "Index is out of bounds")
    points.points[i + points.start]

proc `$`*[T]( points: PointList[T] ): string =
    ## Return a point list as a string
    result = "Points("
    var first = true
    for point in points:
        if first:
            first = false
        else:
            result.add(", ")
        result.add( toStr(point) )
    result.add(")")

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
        points: points.points,
        start: points.start,
        length: leftLength)

    let right = PointList[T](
        points: points.points,
        start: points.start + leftLength,
        length: rightLength)

    return (left: left, right: right)


