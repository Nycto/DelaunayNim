import unittest
import private/triangle
import private/point

type Pnt = tuple[x, y: int]

suite "Triangles should ":

    test "determine whether three points are a triangle":
        let tri = newTriangle[Pnt]( pnt(0, 0), pnt(1, 1), pnt(2, 0) )
        require( isTriangle[Pnt](tri) )

    test "determine that points in a line aren't a triangle":
        let tri = newTriangle[Pnt]( pnt(0, 0), pnt(3, 2), pnt(6, 4) )
        require( not isTriangle[Pnt](tri) )

    test "determine that a triangle contains duplicate points":
        require( not isTriangle[Pnt](
            newTriangle[Pnt]( pnt(0, 0), pnt(3, 2), pnt(3, 2) )
        ) )

        require( not isTriangle[Pnt](
            newTriangle[Pnt]( pnt(0, 0), pnt(3, 2), pnt(0, 0) )
        ) )

        require( not isTriangle[Pnt](
            newTriangle[Pnt]( pnt(3, 2), pnt(3, 2), pnt(0, 0) )
        ) )


