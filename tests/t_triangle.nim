import unittest, helpers
import delaunay/private/triangle
import delaunay/private/point

suite "Triangles should ":

    test "determine whether three points are a triangle":
        let tri = newTriangle( p(0, 0), p(1, 1), p(2, 0) )
        require( isTriangle(tri) )

    test "determine that points in a line aren't a triangle":
        let tri = newTriangle( p(0, 0), p(3, 2), p(6, 4) )
        require( not isTriangle(tri) )

    test "determine that a triangle contains duplicate points":
        require( not isTriangle(
            newTriangle( p(0, 0), p(3, 2), p(3, 2) )
        ) )

        require( not isTriangle(
            newTriangle( p(0, 0), p(3, 2), p(0, 0) )
        ) )

        require( not isTriangle(
            newTriangle( p(3, 2), p(3, 2), p(0, 0) )
        ) )

    test "return whether a point is within a circumcirlcle":

        # Points in a line can't form a triangle
        expect(AssertionError):
            discard isInCircumcircle(
                newTriangle( p(0, 0), p(5, 5), p(10, 10) ),
                p(5, 2)
            )

        # Points in a line can't form a triangle
        expect(AssertionError):
            discard isInCircumcircle(
                newTriangle( p(0, 0), p(0, 5), p(0, 10) ),
                p(5, 2)
            )

        # Throw when two points are shared
        expect(AssertionError):
            discard isInCircumcircle(
                newTriangle( p(0, 0), p(5, 0), p(5, 0) ),
                p(3, 3)
            )

        require( isInCircumcircle(
            newTriangle( p(0, 0), p(5, 0), p(0, 5) ),
            p(3, 3)
        ))

        require( isInCircumcircle(
            newTriangle( p(2, 7), p(0, 0), p(5, 0) ),
            p(3, 3)
        ))

        require( isInCircumcircle(
            newTriangle( p(0, 0), p(5, 5), p(10, 0) ),
            p(5, 2)
        ))

        require( not isInCircumcircle(
            newTriangle( p(0, 0), p(5, 5), p(10, 0) ),
            p(50, 2)
        ))

        require( not isInCircumcircle(
            newTriangle( p(0, 0), p(100, 1), p(200, -10.0) ),
            p(5, 2)
        ))

        require( isInCircumcircle(
            newTriangle( p(0, 0), p(100, 1), p(200, -10.0) ),
            p(100, -300.0)
        ))

        # A point that lies ON the circumcircle is not within it
        require( not isInCircumcircle(
            newTriangle( p(0, 0), p(0, 1), p(1, 1) ),
            p(1, 0)
        ))


