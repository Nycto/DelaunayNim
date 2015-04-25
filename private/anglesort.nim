#
# Sort points based on their angle from a line
#

from point import Point
import algorithm, math, tables, sequtils

type AngleCache = Table[tuple[x, y: float], float]
    ## Cache calculated angles

proc angle[T: Point]( cache: var AngleCache, base: T, a: T, b: T ): float =
    ## Returns the angle between two vectors that share a base point in radians

    let point = (x: b.x, y: b.y)
    if cache.hasKey(point):
        return cache.mget(point)

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



type Direction* = enum ## A rotation direction
    clockwise, counterclockwise

proc angleSort*[T: Point](
    points: openArray[T], direction: Direction,
    center: T, reference: T
): seq[T] =
    ## Sorts a list of points in the given direction, relative to the edge
    ## formed by drawing a line from `center` to `reference`

    # Start by making a copy so we can do an in place sort
    var clone: seq[T] = `@`[T](points)

    # Track angles that have already been calculated to reduce the trig
    var angles = initTable[tuple[x, y: float], float]()

    clone.sort do (a, b: T) -> int:

        let angleToA = angles.angle(center, reference, a)
        let angleToB = angles.angle(center, reference, b)

        if angleToA == angleToB:
            result = cmpDistance(center, a, b)
        elif angleToA == 0:
            result = -1
        elif angleToB == 0:
            result = 1
        elif direction == clockwise:
            result = if angleToA < angleToB: 1 else: -1
        else:
            result = if angleToA < angleToB: -1 else: 1

    # Now filter down to everything under 180 degrees
    return clone.filter do (point: T) -> bool:
        let angle = angles.angle(center, reference, point)
        if direction == clockwise:
            return angle == 0 or angle > PI
        else:
            return angle == 0 or angle < PI


