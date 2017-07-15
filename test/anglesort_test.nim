import unittest, helpers
import delaunay/private/anglesort
import delaunay/private/point
import algorithm


suite "AngleSort should ":

    test "Sort points in clockwise order":
        let iter = [ p(3, 10), p(3, 5), p(8, 4), p(1, 2) ]
            .sort( clockwise, p(4, 0), p(1, 1) )

        require( iter == [ p(1, 2), p(3, 5), p(3, 10), p(8, 4) ] )

    test "Sort points in counter clockwise order":
        let iter = [  p(1, 2), p(0, 1), p(2, 1) ]
            .sort( counterclockwise, p(1, 0), p(5, 1) )

        require( iter == [ p(2, 1), p(1, 2), p(0, 1) ] )


    test "Sort by distance when the angle is the same":
        let iter =
            [ p(1, 2), p(1, 1), p(2, 2), p(1, 1), p(2, 1), p(3, 3) ]
                .sort( counterclockwise, p(0, 0), p(5, 1) )

        require( iter == [
            p(2, 1), p(1, 1), p(1, 1), p(2, 2), p(3, 3), p(1, 2)
        ] )


    test "Handle points with the same slope":

        test "Clockwise":
            let iter = [ p(1, 1), p(5, 0) ]
                .sort( clockwise, p(0, 0), p(4, 4) )

            require( iter == [ p(1, 1), p(5, 0) ] )

        test "CounterClockwise":
            let iter = [ p(1, 1), p(0, 5) ]
                .sort( counterclockwise, p(0, 0), p(4, 4) )

            require( iter == [ p(1, 1), p(0, 5) ] )

    test "Remove points greater than 180 degrees":

        let points = [
            p( 5, 1 ), p( 5, 5 ), p( 3, 5 ),
            p( 0, 5 ),
            p( -3, 5 ), p( -5, 5 ), p( -5, 1 ),
            p( -5, 0 ),
            p( -5, -1 ), p(-5, -5), p(-3, -5),
            p( 0, -5 ),
            p( 1, -5 ), p( 5, -5 ), p( 5, -3 )
        ]

        test "CounterClockwise":
            let iter = points.sort(counterclockwise, p(0, 0), p(5, 0))
            require( iter == points[0..6] )

        test "Clockwise":
            let iter = points.sort(clockwise, p(0, 0), p(5, 0))
            require( iter == points.reversed[0..6] )

    test "Include 0 degree angles when filtering":

        let points = [ p(2, 1), p(3, 3), p(4, 2), p(-1, 2) ]
        let iter = points.sort(clockwise, p(5, 0), p(2, 1))
        require( iter == [ p(2, 1), p(-1, 2), p(3, 3), p(4, 2) ] )

