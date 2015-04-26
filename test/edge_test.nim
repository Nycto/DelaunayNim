import unittest
import private/edge
import private/point

suite "Edge Groups should ":

    test "Track bottom left and right":
        var group = newEdgeGroup[tuple[x, y: float]]()

        expect(EmptyGroupError):
            discard group.bottomRight

        expect(EmptyGroupError):
            discard group.bottomLeft

        group.add( pnt(1, 1), pnt(4, 5) )
        require( pnt(1, 1) == group.bottomRight )
        require( pnt(1, 1) == group.bottomLeft )

        group.add( pnt(1, 0), pnt(10, 4) )
        require( pnt(1, 0) == group.bottomRight )
        require( pnt(1, 0) == group.bottomLeft )

        group.add( pnt(2, 0), pnt(1, 9) )
        require( pnt(2, 0) == group.bottomRight )
        require( pnt(1, 0) == group.bottomLeft )

        group.add( pnt(0, 0), pnt(1, 9) )
        require( pnt(2, 0) == group.bottomRight )
        require( pnt(0, 0) == group.bottomLeft )
