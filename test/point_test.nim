import unittest
import private/point

suite "PointLists should ":

    test "Remove duplicates":
        require(
            @[ pnt(1, 2), pnt(2, 1) ] ==
            @( newPointList([ pnt(1, 2), pnt(2, 1) ]) )
        )

        require(
            @[ pnt(1, 2), pnt(2, 1) ] ==
            @( newPointList([ pnt(1, 2), pnt(2, 1), pnt(1, 2), pnt(2, 1) ]) )
        )

    test "Sort from left to right, bottom to top":
        require(
            @[ pnt(0, 5), pnt(3, 3), pnt(5, 1) ] ==
            @(newPointList([ pnt(5, 1), pnt(3, 3), pnt(0, 5) ]))
        )

        require(
            @[ pnt(0, 1), pnt(0, 3), pnt(0, 5) ] ==
            @(newPointList([ pnt(0, 5), pnt(0, 1), pnt(0, 3) ]))
        )

        require(
            @[
                pnt(0, 1), pnt(1, 0), pnt(1, 2), pnt(1, 3), pnt(2, 1),
                pnt(3, 3), pnt(4, 2), pnt(5, 0), pnt(5, 1), pnt(5, 3)
            ] ==
            @(newPointList([
                pnt(4, 2), pnt(5, 3), pnt(2, 1), pnt(0, 1), pnt(5, 0),
                pnt(3, 3), pnt(5, 1), pnt(1, 2), pnt(1, 0), pnt(1, 3)
            ]))
        )

