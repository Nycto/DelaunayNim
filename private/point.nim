#
# Functions for interacting with points
#

# A type interface for dealing with points
type
    Point* = generic p
        p.x is int or float
        p.y is int or float


# Creates a point
proc pnt*[T: int or float] ( x, y: T ): tuple[x, y: T] =
    result = (x, y)


