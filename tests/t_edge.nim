import unittest, sequtils, algorithm, helpers
import delaunay/private/edge
import delaunay/private/point
import delaunay/private/anglesort

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

        group.add( p(1, 1), p(4, 5) )
        require( p(1, 1) == group.bottomRight )
        require( p(1, 1) == group.bottomLeft )

        group.add( p(1, 0), p(10, 4) )
        require( p(1, 0) == group.bottomRight )
        require( p(1, 0) == group.bottomLeft )

        group.add( p(2, 0), p(1, 9) )
        require( p(2, 0) == group.bottomRight )
        require( p(1, 0) == group.bottomLeft )

        group.add( p(0, 0), p(1, 9) )
        require( p(2, 0) == group.bottomRight )
        require( p(0, 0) == group.bottomLeft )

    test "Iterate over all edges":
        var group = newEdgeGroup[tuple[x, y: float]]()

        group.add( p(1, 1), p(4, 5) )
        group.add( p(1, 1), p(2, 2) )
        group.add( p(4, 5), p(2, 2) )

        require(group == @[
            p(1, 1) -> p(2, 2),
            p(1, 1) -> p(4, 5),
            p(2, 2) -> p(4, 5)
        ])

    test "Allow edges to be removed":
        var group = newEdgeGroup[tuple[x, y: float]]()

        group.add( p(1, 1), p(4, 5) )
        group.add( p(1, 1), p(2, 2) )
        group.add( p(4, 5), p(2, 2) )
        group.remove( p(1, 1), p(2, 2) )

        require(group == @[
            p(1, 1) -> p(4, 5),
            p(2, 2) -> p(4, 5)
        ])

    test "Return connected points":

        var group = newEdgeGroup[tuple[x, y: float]]()
        group.add( p(1, 1), p(4, 5) )
        group.add( p(1, 1), p(2, 2) )
        group.add( p(4, 5), p(2, 2) )
        group.add( p(4, 5), p(6, 6) )

        let connections = group.connected( p(1, 1) )

        require( connections == @[ p(2, 2),  p(4, 5) ] )

    test "Add edge groups together":

        var one = newEdgeGroup[tuple[x, y: float]]()
        one.add( p(1, 1), p(4, 5) )
        one.add( p(1, 1), p(2, 2) )
        one.add( p(4, 5), p(2, 2) )

        var two = newEdgeGroup[tuple[x, y: float]]()
        two.add( p(1, 1), p(6, 3) )
        two.add( p(6, 3), p(8, 8) )

        one.add(two)

        require( one == @[
            p(1, 1) -> p(2, 2),
            p(1, 1) -> p(4, 5),
            p(1, 1) -> p(6, 3),
            p(2, 2) -> p(4, 5),
            p(6, 3) -> p(8, 8)
        ])


