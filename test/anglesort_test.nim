import unittest
import private/anglesort
import private/point
import algorithm


suite "AngleSort should ":

    test "Sort points in clockwise order":
        let iter = [ pnt(3, 10), pnt(3, 5), pnt(8, 4), pnt(1, 2) ]
            .angleSort( clockwise, pnt(4, 0), pnt(1, 1) )

        require(iter == @[ pnt(1, 2), pnt(3, 5), pnt(3, 10), pnt(8, 4) ])

    test "Sort points in counter clockwise order":
        let iter = [  pnt(1, 2), pnt(0, 1), pnt(2, 1) ]
            .angleSort( counterclockwise, pnt(1, 0), pnt(5, 1) )

        require( iter == @[ pnt(2, 1), pnt(1, 2), pnt(0, 1) ] )


    test "Sort by distance when the angle is the same":
        let iter =
            [ pnt(1, 2), pnt(1, 1), pnt(2, 2), pnt(1, 1), pnt(2, 1), pnt(3, 3) ]
                .angleSort( counterclockwise, pnt(0, 0), pnt(5, 1) )

        require( iter == @[
            pnt(2, 1), pnt(1, 1), pnt(1, 1), pnt(2, 2), pnt(3, 3), pnt(1, 2)
        ] )


    test "Handle points with the same slope":

        test "Clockwise":
            let iter = [ pnt(1, 1), pnt(5, 0) ]
                .angleSort( clockwise, pnt(0, 0), pnt(4, 4) )

            require( iter == @[ pnt(1, 1), pnt(5, 0) ] )

        test "CounterClockwise":
            let iter = [ pnt(1, 1), pnt(0, 5) ]
                .angleSort( counterclockwise, pnt(0, 0), pnt(4, 4) )

            require( iter == @[ pnt(1, 1), pnt(0, 5) ] )

    test "Remove points greater than 180 degrees":

        let points = [
            pnt( 5, 1 ), pnt( 5, 5 ), pnt( 3, 5 ),
            pnt( 0, 5 ),
            pnt( -3, 5 ), pnt( -5, 5 ), pnt( -5, 1 ),
            pnt( -5, 0 ),
            pnt( -5, -1 ), pnt(-5, -5), pnt(-3, -5),
            pnt( 0, -5 ),
            pnt( 1, -5 ), pnt( 5, -5 ), pnt( 5, -3 )
        ];

        test "CounterClockwise":
            let iter = points.angleSort(counterclockwise, pnt(0, 0), pnt(5, 0))
            require( iter == points[0..6] )

        test "Clockwise":
            let iter = points.angleSort(clockwise, pnt(0, 0), pnt(5, 0))
            require( iter == points.reversed[0..6] )

