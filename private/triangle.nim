#
# Triangle procs and objects
#

import point


# This may come as a suprise, but a triangle is made up of three points
type
    Triangle*[T] = object
        a, b, c: T


# Constructor
proc newTriangle*[T: Point]( a: T, b: T, c: T ): Triangle[T] =
    result = Triangle[T](a: a, b: b, c: c)


# Determines whether three points actualy form a valid triangle. The only way
# this returns false is if they form a line
proc isTriangle*[T: Point]( tri: Triangle[T] ): bool =
    return (tri.b.y - tri.a.y) * (tri.c.x - tri.b.x) !=
        (tri.c.y - tri.b.y) * (tri.b.x - tri.a.x)


