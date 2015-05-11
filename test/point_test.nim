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

    test "Calculate the length of a point list":
        let points = newPointList([ pnt(1, 2), pnt(2, 1) ])
        require( points.len == 2 )

    test "Allow array access to individual values":
        let points = newPointList([ pnt(1, 2), pnt(2, 1) ])
        require( points[0] == pnt(1, 2) )
        require( points[1] == pnt(2, 1) )
        expect(IndexError):
            discard points[2]

    test "Split an even point list in half":
        let points = newPointList([
            pnt(1, 2), pnt(2, 1), pnt(4, 5), pnt(6, 3) ])
        let (left, right) = points.split
        require( @left == @[ pnt(1, 2), pnt(2, 1) ] )
        require( @right == @[ pnt(4, 5), pnt(6, 3) ] )

    test "Split an odd point list in half":
        let points = newPointList([
            pnt(1, 2), pnt(2, 1), pnt(4, 5), pnt(6, 3), pnt(7, 8) ])
        let (left, right) = points.split
        require( @left == @[ pnt(1, 2), pnt(2, 1), pnt(4, 5) ] )
        require( @right == @[ pnt(6, 3), pnt(7, 8) ] )

    test "Throw when trying to split a small list":
        let points = newPointList([ pnt(1, 2), pnt(2, 1), pnt(4, 5) ])
        expect(CantSplitError):
            discard points.split

    test "Allow array access after a split":
        let points = newPointList([
            pnt(1, 2), pnt(2, 1), pnt(4, 5), pnt(6, 3) ])
        let (left, right) = points.split

        require( left[0] == pnt(1, 2) )
        require( left[1] == pnt(2, 1) )
        expect(IndexError):
            discard left[2]

        require( right[0] == pnt(4, 5) )
        require( right[1] == pnt(6, 3) )
        expect(IndexError):
            discard right[2]

