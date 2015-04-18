#
# Functions for interacting with points
#

# A type interface for dealing with points
type
    Point = generic p
        p.x is integer
        p.y is integer

# A phantom type that guaranatees its contents are unique and sorted
type UniqSortedPoints = distinct seq[Point]

# Given a list of points, sorts and dedupes them
proc uniqSorted* ( points: seq[Point] ): UniqSortedPoints =
    discard

