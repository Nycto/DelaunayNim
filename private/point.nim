#
# Functions for interacting with points
#

# A type interface for dealing with points
type
    Point* = generic p
        p.x is float
        p.y is float


# Creates a point
proc pnt*( x, y: float ): tuple[x, y: float] =
    result = (x, y)


