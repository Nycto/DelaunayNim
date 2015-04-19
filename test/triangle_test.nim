import unittest
import private/triangle
import private/point

suite "Triangles should ":

    test "determine whether three points are a triangle":
        let tri = newTriangle( pnt(0, 0), pnt(1, 1), pnt(2, 0) )
        require( isTriangle(tri) )

    test "determine that points in a line aren't a triangle":
        let tri = newTriangle( pnt(0, 0), pnt(3, 2), pnt(6, 4) )
        require( not isTriangle(tri) )

    test "determine that a triangle contains duplicate points":
        require( not isTriangle(
            newTriangle( pnt(0, 0), pnt(3, 2), pnt(3, 2) )
        ) )

        require( not isTriangle(
            newTriangle( pnt(0, 0), pnt(3, 2), pnt(0, 0) )
        ) )

        require( not isTriangle(
            newTriangle( pnt(3, 2), pnt(3, 2), pnt(0, 0) )
        ) )

    test "return whether a point is within a circumcirlcle":

        # Points in a line can't form a triangle
        expect(AssertionError):
            discard isInCircumcircle(
                newTriangle( pnt(0, 0), pnt(5, 5), pnt(10, 10) ),
                pnt(5, 2)
            )

        # Points in a line can't form a triangle
        expect(AssertionError):
            discard isInCircumcircle(
                newTriangle( pnt(0, 0), pnt(0, 5), pnt(0, 10) ),
                pnt(5, 2)
            )

        # Throw when two points are shared
        expect(AssertionError):
            discard isInCircumcircle(
                newTriangle( pnt(0, 0), pnt(5, 0), pnt(5, 0) ),
                pnt(3, 3)
            )

        require( isInCircumcircle(
            newTriangle( pnt(0, 0), pnt(5, 0), pnt(0, 5) ),
            pnt(3, 3)
        ))

        require( isInCircumcircle(
            newTriangle( pnt(2, 7), pnt(0, 0), pnt(5, 0) ),
            pnt(3, 3)
        ))

        require( isInCircumcircle(
            newTriangle( pnt(0, 0), pnt(5, 5), pnt(10, 0) ),
            pnt(5, 2)
        ))

        require( not isInCircumcircle(
            newTriangle( pnt(0, 0), pnt(5, 5), pnt(10, 0) ),
            pnt(50, 2)
        ))

        require( not isInCircumcircle(
            newTriangle( pnt(0, 0), pnt(100, 1), pnt(200, -10.0) ),
            pnt(5, 2)
        ))

        require( isInCircumcircle(
            newTriangle( pnt(0, 0), pnt(100, 1), pnt(200, -10.0) ),
            pnt(100, -300.0)
        ))

        # A point that lies ON the circumcircle is not within it
        require( not isInCircumcircle(
            newTriangle( pnt(0, 0), pnt(0, 1), pnt(1, 1) ),
            pnt(1, 0)
        ))


