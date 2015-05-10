import unittest, sequtils, helpers, algorithm
import private/point
import private/edge
import delaunay


proc assertEdges( expected: seq[tuple[a, b: tuple[x, y: float]]] ) =
    ## Asserts that a set of edges is calculated when their points are
    ## extracted and triangulated

    # Pull all the points from all the edges into a list
    var points: seq[tuple[x, y: float]] = @[]
    for edge in expected:
        points.add(edge.a)
        points.add(edge.b)

    # Run a triangulation based on the extracted points
    var edges = toSeq( triangulate(points) )

    # Sort the edges to remove any non-determinism from the tests
    edges.sort do (a, b: tuple[a, b: tuple[x, y: float]]) -> int:
        let aCompared = a.a <=> b.a
        return if aCompared == 0: b.a <=> b.b else: aCompared

    require( edges == expected )


suite "Delaunay triangulation should ":

    test "Return empty for empty input":
        assertEdges( @[] )

    test "Return empty for a single point":
        let edges = toSeq( triangulate(@[ pnt(1, 1) ]) )
        let empty: seq[tuple[a, b: tuple[x, y: float]]] = @[]
        require( edges == empty )

    test "Return a single edge with two points":
        assertEdges( @[
            (a: pnt(1, 1), b: pnt(4, 4))
        ])

    test "Return three edges for a triangle":
        assertEdges( @[
            (a: pnt(0, 0), b: pnt(2, 2)),
            (a: pnt(0, 0), b: pnt(4, 0)),
            (a: pnt(2, 2), b: pnt(4, 0))
        ])

    test "Return two edges for a line":
        assertEdges( @[
            (a: pnt(0, 0), b: pnt(2, 2)),
            (a: pnt(2, 2), b: pnt(4, 4))
        ])

