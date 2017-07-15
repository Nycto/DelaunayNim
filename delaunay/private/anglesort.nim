#
# Sort points based on their angle from a line
#

import delaunay/private/point
import options, algorithm, math, tables, sequtils

type AngleCache = Table[tuple[x, y: float], float]
    ## Cache calculated angles

proc angle[T: Point]( cache: var AngleCache, base: T, a: T, b: T ): float =
    ## Returns the angle between two vectors that share a base point in radians

    let point = (x: b.x, y: b.y)
    if cache.hasKey(point):
        return cache[point]

    let v1 = (x: a.x - base.x, y: a.y - base.y)
    let v2 = (x: b.x - base.x, y: b.y - base.y)

    # @TODO: This could probably be made faster by using a heuristic
    # instead of calling arctan2. These pages have a few options:
    # https://stackoverflow.com/questions/6989100/sort-points-in-clockwise-order
    # https://stackoverflow.com/questions/16542042/fastest-way-to-sort-vectors-by-angle-without-actually-computing-that-angle
    let radians = arctan2(v2.y, v2.x) - arctan2(v1.y, v1.x)
    let angle = if radians >= 0: radians else: 2 * PI + radians

    # Cache the result to reduce overhead for future lookups
    cache.add(point, angle)

    return angle


proc cmpDistance[T]( base, a, b: T ): int =
    ## Compares the distance between two points

    proc dist (p: T): float =
        ## The squared distance of a point from 'base'
        return (p.x - base.x) * (p.x - base.x) + (p.y - base.y) * (p.y - base.y)

    let compared = dist(a) - dist(b)

    return if compared == 0: 0 elif compared < 0: -1 else: 1



type AngleSorted*[T] = distinct seq[T] ## \
    ## A list of points that have been sorted by angle

proc `==`*[T]( actual: AngleSorted[T], expected: openArray[T] ): bool =
    ## Compare an angle sorted value to an array
    return system.`==`( seq[T](actual), @expected )

proc first*[T]( actual: AngleSorted[T] ): Option[T] =
    ## Returns the first item
    let asSeq = seq[T](actual)
    return if asSeq.len == 0: none(T) else: some(asSeq[0])

proc `$`*[T: Point]( points: AngleSorted[T] ): string =
    ## Convert to a string
    result = "AngleSorted("
    var first = true
    for point in items(seq[T](points)):
        if first:
            first = false
        else:
            result.add(", ")
        result.add( toStr(point) )
    result.add(")")

type Direction* = enum ## \
    ## A rotation direction
    clockwise, counterclockwise

proc sort*[T: Point](
    points: openArray[T], direction: Direction,
    center: T, reference: T
): AngleSorted[T] =
    ## Sorts a list of points in the given direction, relative to the edge
    ## formed by drawing a line from `center` to `reference`

    # Start by making a copy so we can do an in place sort
    var output: seq[T] = `@`[T](points)

    # Track angles that have already been calculated to reduce the trig
    var angles = initTable[tuple[x, y: float], float]()

    output.sort do (a, b: T) -> int:

        let angleToA = angles.angle(center, reference, a)
        let angleToB = angles.angle(center, reference, b)

        if angleToA == angleToB:
            return cmpDistance(center, a, b)
        elif angleToA == 0:
            return -1
        elif angleToB == 0:
            return 1
        elif direction == clockwise:
            return if angleToA < angleToB: 1 else: -1
        else:
            return if angleToA < angleToB: -1 else: 1

    ## Now filter down to everything under 180 degrees
    for i in 0..<output.len:

        let angle = angles.angle(center, reference, output[i])

        if angle == 0:
            discard
        elif direction == clockwise and angle > PI:
            discard
        elif direction == counterclockwise and angle < PI:
            discard
        else:
            # Trim the result once we see the first point that is beyond 180
            # degrees.  The points are sorted, so the rest are guaranteed to be
            # over 180 too
            output.setLen(i)
            break

    return AngleSorted(output)

iterator items*[T]( points: AngleSorted[T] ): T =
    ## Iterate over each point
    for point in items( seq[T](points) ):
        yield point


