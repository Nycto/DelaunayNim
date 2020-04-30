#
# Helpers to make testing easier
#

import sequtils, sets
import delaunay
import delaunay/private/edge
import delaunay/private/point

proc p*( x, y: float ): tuple[x, y: float] =
    ## Creates a point
    result = (x, y)

proc `->`*( a, b: tuple[x, y: float] ): Edge[tuple[x, y: float]] =
    ## Creates an edge from two tuples
    result = (a: a, b: b)

proc `==`*[T]( actual: seq[T], expected: openArray[T] ): bool =
    ## Allows you to compare a sequence to an array
    result = system.`==`( actual, @expected )

proc `==`*[T]( actual: iterator: T, expected: openArray[T] ): bool =
    ## Allows you to compare an iterator to an array
    let iterated = toseq( actual() )
    let sequence = @expected
    result = iterated == sequence

proc `$`*[T]( iter: iterator: T ): string =
    ## Coverts an iterator to a string
    result = `$`(toseq(iter()))


type EdgeList* = seq[Edge[tuple[x, y: float]]]

proc edges*( expected: varargs[Edge[tuple[x, y: float]]] ): EdgeList =
    return EdgeList(@expected)

proc `$`*( edges: EdgeList ): string =
    result = "EdgeList("
    var first = true
    for edge in edges:
        if first:
            first = false
        else:
            result.add(", ")
        result.add( toStr(edge.a) & " -> " & toStr(edge.b) )
    result.add(")")

proc points*( edges: EdgeList ): seq[tuple[x, y: float]] =
    # Pull all the points from all the edges into a list
    result = @[]
    for edge in seq[Edge[tuple[x, y: float]]](edges):
        result.add(edge.a)
        result.add(edge.b)

proc triangulate*( expected: EdgeList ): EdgeList =
    ## Extract the points from an edge list and run a triangulation
    let pointList = points(expected)
    let asSeq = toSeq( triangulate(pointList) )
    return EdgeList( asSeq )

template `==`*( expected, actual: EdgeList ): bool =
    ## Compare two edge lists
    var expectedSet = toHashSet(expected)
    var actualSet = toHashSet(actual)

    for point in difference(expectedSet, actualSet):
        checkpoint("Missing: " & toStr(point.a) & " -> " & toStr(point.b))

    for extra in difference(actualSet, expectedSet):
        checkpoint("Extra: " & toStr(extra.a) & " -> " & toStr(extra.b) )

    actualSet == expectedSet

