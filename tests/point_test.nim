import unittest, helpers
import delaunay/private/point

suite "PointLists should ":

    test "Remove duplicates":
        require(
            @[ p(1, 2), p(2, 1) ] ==
            @( newPointList([ p(1, 2), p(2, 1) ]) )
        )

        require(
            @[ p(1, 2), p(2, 1) ] ==
            @( newPointList([ p(1, 2), p(2, 1), p(1, 2), p(2, 1) ]) )
        )

    test "Sort from left to right, bottom to top":
        require(
            @[ p(0, 5), p(3, 3), p(5, 1) ] ==
            @(newPointList([ p(5, 1), p(3, 3), p(0, 5) ]))
        )

        require(
            @[ p(0, 1), p(0, 3), p(0, 5) ] ==
            @(newPointList([ p(0, 5), p(0, 1), p(0, 3) ]))
        )

        require(
            @[
                p(0, 1), p(1, 0), p(1, 2), p(1, 3), p(2, 1),
                p(3, 3), p(4, 2), p(5, 0), p(5, 1), p(5, 3)
            ] ==
            @(newPointList([
                p(4, 2), p(5, 3), p(2, 1), p(0, 1), p(5, 0),
                p(3, 3), p(5, 1), p(1, 2), p(1, 0), p(1, 3)
            ]))
        )

    test "Calculate the length of a point list":
        let points = newPointList([ p(1, 2), p(2, 1) ])
        require( points.len == 2 )

    test "Allow array access to individual values":
        let points = newPointList([ p(1, 2), p(2, 1) ])
        require( points[0] == p(1, 2) )
        require( points[1] == p(2, 1) )
        expect(IndexError):
            discard points[2]

    test "Split an even point list in half":
        let points = newPointList([
            p(1, 2), p(2, 1), p(4, 5), p(6, 3) ])
        let (left, right) = points.split
        require( @left == @[ p(1, 2), p(2, 1) ] )
        require( @right == @[ p(4, 5), p(6, 3) ] )

    test "Split an odd point list in half":
        let points = newPointList([
            p(1, 2), p(2, 1), p(4, 5), p(6, 3), p(7, 8) ])
        let (left, right) = points.split
        require( @left == @[ p(1, 2), p(2, 1), p(4, 5) ] )
        require( @right == @[ p(6, 3), p(7, 8) ] )

    test "Allow splitting a split":
        let points = newPointList([
            p(0, 1), p(1, 0), p(1, 2), p(1, 3), p(2, 1),
            p(3, 3), p(4, 2), p(5, 0), p(5, 1), p(5, 3) ])

        let (left, right) = points.split

        let (rLeft, rRight) = right.split
        require( @rRight == @[ p(5, 1), p(5, 3) ] )
        require( @rLeft == @[ p(3, 3), p(4, 2), p(5, 0) ] )

        let (lLeft, lRight) = left.split
        require( @lRight == @[ p(1, 3), p(2, 1) ] )
        require( @lLeft == @[ p(0, 1), p(1, 0), p(1, 2) ] )

    test "Throw when trying to split a small list":
        let points = newPointList([ p(1, 2), p(2, 1), p(4, 5) ])
        expect(CantSplitError):
            discard points.split

    test "Allow array access after a split":
        let points = newPointList([
            p(1, 2), p(2, 1), p(4, 5), p(6, 3) ])
        let (left, right) = points.split

        require( left[0] == p(1, 2) )
        require( left[1] == p(2, 1) )
        expect(IndexError):
            discard left[2]

        require( right[0] == p(4, 5) )
        require( right[1] == p(6, 3) )
        expect(IndexError):
            discard right[2]

