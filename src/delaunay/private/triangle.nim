#
# Triangle procs and objects
#

import delaunay/private/point


type Triangle*[T] = object
    ## This may come as a suprise, but a triangle is made up of three points
    a*, b*, c*: T

proc newTriangle*[T: Point]( a: T, b: T, c: T ): Triangle[T] =
    ## Constructor
    result = Triangle[T](a: a, b: b, c: c)

proc `$`*[T: Point]( tri: Triangle[T] ): string =
    result = "Triangle(" &
        toStr(tri.a) & ", " &
        toStr(tri.b) & ", " &
        toStr(tri.c) & ")"

proc isTriangle*[T: Point]( tri: Triangle[T] ): bool =
    ## Determines whether three points actualy form a valid triangle. The only
    ## way this returns false is if they form a line
    return (tri.b.y - tri.a.y) * (tri.c.x - tri.b.x) !=
        (tri.c.y - tri.b.y) * (tri.b.x - tri.a.x)

proc isInCircumcircle*[T: Point]( tri: Triangle[T], point: T ): bool =
    ## Returns whether a point exists within the circumcircle of a triangle

    if not isTriangle[T](tri):
        raise newException(
            AssertionError,
            "Three given points don't form a triangle: " & $tri
        )

    let a = tri.a
    let b = tri.b
    let c = tri.c

    # If we are dealing with any horizontal lines, they cause the slope
    # to be infinity. The easy solution is to just use different edges
    if a.y == b.y or b.y == c.y:
        return isInCircumCircle[T]( newTriangle[T](tri.c, tri.a, tri.b), point )

    # Calculate the slope of each of the perpendicular lines. In
    # the equation `y = mx + b`, this is the `m`
    let slopeAB = -1 * ( (b.x - a.x) / (b.y - a.y) )
    let slopeBC = -1 * ( (c.x - b.x) / (c.y - b.y) )

    # Calculate the y-intercept of each of the perpendicular lines. In
    # the equation `y = mx + b`, this is the `b`
    let yinterceptAB = ( -1 * slopeAB * (a.x + b.x) + a.y + b.y ) / 2
    let yinterceptBC = ( -1 * slopeBC * (b.x + c.x) + b.y + c.y ) / 2

    # The centroid of the circumcircle
    let centerX = (yinterceptBC - yinterceptAB) / (slopeAB - slopeBC)
    let centerY = (slopeAB * centerX) + yinterceptAB

    # The radius of the circumcircle
    let radius = ( (centerX - a.x) * (centerX - a.x) ) +
        ( (centerY - a.y) * (centerY - a.y) )

    # The distance of the point being checked from the centroid
    let distance = ( (centerX - point.x) * (centerX - point.x) ) +
        ( (centerY - point.y) * (centerY - point.y) )

    # If the distance is less than the radius, the point is in the circle.
    # Note that we consider points on the circumference to be outside
    # of the circumcircle
    return distance < radius


