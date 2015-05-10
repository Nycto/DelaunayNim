import unittest, sequtils, helpers, algorithm
import private/point
import private/edge
import delaunay

proc assertEdges(
    points: openArray[tuple[x, y: float]],
    expected: openArray[tuple[a, b: tuple[x, y: float]]]
) =
    ## Asserts that a set of edges is calculated by the given points

    var edges = toSeq( triangulate(points) )

    # Sort the edges to remove any non-determinism from the tests
    edges.sort do (a, b: tuple[a, b: tuple[x, y: float]]) -> int:
        let aCompared = a.a <=> b.a
        return if aCompared == 0: b.a <=> b.b else: aCompared

    let expect = toSeq(items(expected))

    require( edges == expect )

proc assertEdges( expected: varargs[tuple[a, b: tuple[x, y: float]]] ) =
    ## Asserts that a set of edges is calculated when their points are
    ## extracted and triangulated

    # Pull all the points from all the edges into a list
    var points: seq[tuple[x, y: float]] = @[]
    for edge in expected:
        points.add(edge.a)
        points.add(edge.b)

    assertEdges( points, toSeq(items(expected)) )


suite "Delaunay triangulation should ":

    test "Return empty for empty input":
        assertEdges( @[], @[] )

    test "Return empty for a single point":
        let edges = toSeq( triangulate(@[ pnt(1, 1) ]) )
        let empty: seq[tuple[a, b: tuple[x, y: float]]] = @[]
        require( edges == empty )

    test "Return a single edge with two points":
        assertEdges( pnt(1, 1) -> pnt(4, 4) )

    test "Return three edges for a triangle":
        assertEdges(
            pnt(0, 0) -> pnt(2, 2),
            pnt(0, 0) -> pnt(4, 0),
            pnt(2, 2) -> pnt(4, 0)
        )

    test "Return two edges for a line":
        assertEdges(
            [ pnt(0, 0), pnt(2, 2), pnt(4, 4) ],
            [ pnt(0, 0) -> pnt(2, 2), pnt(2, 2) -> pnt(4, 4) ]
        )

        assertEdges(
            [ pnt(0, 0), pnt(4, 4), pnt(2, 2) ],
            [ pnt(0, 0) -> pnt(2, 2), pnt(2, 2) -> pnt(4, 4) ]
        )

        assertEdges(
            [ pnt(4, 4), pnt(0, 0), pnt(2, 2) ],
            [ pnt(0, 0) -> pnt(2, 2), pnt(2, 2) -> pnt(4, 4) ]
        )


