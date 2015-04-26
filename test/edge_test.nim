import unittest, sequtils
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

    test "Iterate over all edges":
        var group = newEdgeGroup[tuple[x, y: float]]()

        group.add( pnt(1, 1), pnt(4, 5) )
        group.add( pnt(1, 1), pnt(2, 2) )
        group.add( pnt(4, 5), pnt(2, 2) )

        let edges = toSeq(group.edges)

        # This is kind of a crappy test in that it depends on potentially
        # non-deterministic sorting within Maps and Sets, but its enough for now
        require( edges == @[
            (a: pnt(1, 1), b: pnt(4, 5) ),
            (a: pnt(1, 1), b: pnt(2, 2) ),
            (a: pnt(4, 5), b: pnt(2, 2) )
        ])

