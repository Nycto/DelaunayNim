import unittest, sequtils, algorithm
import private/edge
import private/point
import private/anglesort

proc `==`[T]( actual: EdgeGroup[T], expected: seq[Edge[T]] ): bool =
    var edges = toSeq(actual.edges)

    edges.sort do (a, b: Edge[T]) -> int:
        return a <=> b

    # This is kind of a crappy test in that it depends on potentially
    # non-deterministic sorting within Maps and Sets, but its enough for now
    system.`==`(edges, expected)


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

        require(group == @[
            (a: pnt(1, 1), b: pnt(2, 2) ),
            (a: pnt(1, 1), b: pnt(4, 5) ),
            (a: pnt(2, 2), b: pnt(4, 5) )
        ])

    test "Allow edges to be removed":
        var group = newEdgeGroup[tuple[x, y: float]]()

        group.add( pnt(1, 1), pnt(4, 5) )
        group.add( pnt(1, 1), pnt(2, 2) )
        group.add( pnt(4, 5), pnt(2, 2) )
        group.remove( pnt(1, 1), pnt(2, 2) )

        require(group == @[
            (a: pnt(1, 1), b: pnt(4, 5) ),
            (a: pnt(2, 2), b: pnt(4, 5) )
        ])

    test "Return connected points":

        var group = newEdgeGroup[tuple[x, y: float]]()
        group.add( pnt(1, 1), pnt(4, 5) )
        group.add( pnt(1, 1), pnt(2, 2) )
        group.add( pnt(4, 5), pnt(2, 2) )
        group.add( pnt(4, 5), pnt(6, 6) )

        let connections = group.connected( pnt(1, 1) )

        require( connections == @[ pnt(4, 5), pnt(2, 2) ] )

    test "Add edge groups together":

        var one = newEdgeGroup[tuple[x, y: float]]()
        one.add( pnt(1, 1), pnt(4, 5) )
        one.add( pnt(1, 1), pnt(2, 2) )
        one.add( pnt(4, 5), pnt(2, 2) )

        var two = newEdgeGroup[tuple[x, y: float]]()
        two.add( pnt(1, 1), pnt(6, 3) )
        two.add( pnt(6, 3), pnt(8, 8) )

        one.add(two)

        require( one == @[
            (a: pnt(1, 1), b: pnt(2, 2) ),
            (a: pnt(1, 1), b: pnt(4, 5) ),
            (a: pnt(1, 1), b: pnt(6, 3) ),
            (a: pnt(2, 2), b: pnt(4, 5) ),
            (a: pnt(6, 3), b: pnt(8, 8) )
        ])


