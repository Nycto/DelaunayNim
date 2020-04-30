#
# Edges
#

import delaunay/private/anglesort, delaunay/private/point
import tables, sets, options, sequtils

type Edge*[T] = tuple[a, b: T] ## \
    ## Two connected points

proc `->`*[T: Point]( a, b: T ): Edge[T] {.inline.} =
    ## Creates an edge from two points
    return if (a <=> b) > 0: (a: b, b: a) else: (a: a, b: b)

proc `<=>`*[T: Point]( a, b: Edge[T] ): int =
    ## Sorts two edges
    let aCompared = a.a <=> b.a
    if aCompared == 0:
        return a.b <=> b.b
    else:
        return aCompared


type EdgeGroup*[T] = object ## \
    ## A group of edges

    # A map of points to the points they are connected to
    connections: Table[T, HashSet[T]]

    # Tracks the bottom-left point in this group of edges
    lowerLeft: Option[T]

    # Tracks the bottom-right point in this group of edges
    lowerRight: Option[T]


type EmptyGroupError* = object of Exception ## \
    ## Thrown when trying to read something out of a group without edges


proc add*[T: Point] ( group: var EdgeGroup[T], one, two: T )


proc newEdgeGroup*[T: Point]( edges: varargs[Edge[T]] ): EdgeGroup[T] =
    ## Creates a new, empty edge group
    result = EdgeGroup[T](
        connections: initTable[T, HashSet[T]](),
        lowerLeft: none(T),
        lowerRight: none(T)
    )

    for edge in edges:
        add( result, edge.a, edge.b )


proc potentialBottom[T: Point]( group: var EdgeGroup[T], point: T ) =
    ## Compares a point to the bottom most points already tracked. Replaces
    ## those points with this one if this is lower. Adds it if it is on the
    ## same level.

    if isNone(group.lowerLeft) or point.y < group.lowerLeft.get.y:
        group.lowerLeft = some(point)
        group.lowerRight = some(point)

    elif point.y == group.lowerLeft.get.y:
        if point.x < group.lowerLeft.get.x:
            group.lowerLeft = some(point)
        if point.x > group.lowerRight.get.x:
            group.lowerRight = some(point)

proc connect[T: Point]( group: var EdgeGroup[T], base, other: T ) =
    ## Adds a point and its connection to his group

    if group.connections.hasKey(base):
        group.connections[base].incl(other)
    else:
        group.connections.add(base, toHashSet([ other ]))


proc add*[T: Point] ( group: var EdgeGroup[T], one, two: T ) =
    ## Adds an edge to this group
    group.potentialBottom( one )
    group.potentialBottom( two )
    group.connect( one, two )
    group.connect( two, one )

proc add*[T: Point] ( group: var EdgeGroup[T], other: EdgeGroup[T] ) =
    ## Adds an entire EdgeGroup to this one
    for point, edges in pairs( other.connections ):
        if group.connections.hasKey(point):
            for other in items( edges ):
                group.connections[point].incl(other)
        else:
            group.connections.add(point, edges)

    if other.lowerLeft.isSome:
        group.potentialBottom( other.lowerLeft.get )

    if other.lowerRight.isSome:
        group.potentialBottom( other.lowerRight.get )


proc remove*[T: Point] ( group: var EdgeGroup[T], one, two: T ) =
    ## Removes an edge from this group. Note that the two points are still
    ## considered as part of this EdgeGroup when considering the bottom left
    ## and bottom right points
    if group.connections.hasKey(one):
        group.connections[one].excl(two)
    if group.connections.hasKey(two):
        group.connections[two].excl(one)

proc bottomRight*[T: Point]( group: EdgeGroup[T] ): T =
    ## Returns the bottom right point in this edge group
    if isNone group.lowerRight:
        raise newException(EmptyGroupError, "EdgeGroup is empty")
    return group.lowerRight.get

proc bottomLeft*[T: Point]( group: EdgeGroup[T] ): T =
    ## Returns the bottom left point in this edge group
    if isNone group.lowerLeft:
        raise newException(EmptyGroupError, "EdgeGroup is empty")
    return group.lowerLeft.get

iterator edges*[T: Point]( group: EdgeGroup[T] ): Edge[T] =
    ## Iterates over all the edges in a group

    var seen = initHashSet[T]()
    for key in group.connections.keys:
        seen.incl(key)
        for point in `[]`(group.connections, key).items:
            if not seen.contains(point):
                yield (key -> point)


proc `$`*[T: Point]( group: EdgeGroup[T] ): string =
    ## Creates a readable string from an edge group
    result = "EdgeGroup( "
    var first = true
    for edge in edges( group ):
        if first:
            first = false
        else:
            result.add(", ")
        result.add( toStr(edge.a) & " -> " & toStr(edge.b) )
    result.add(" )")


type MissingPointError* = object of Exception ## \
    ## Thrown when trying to read connections of a point that isn't in a group

proc connected*[T: Point]( group: EdgeGroup[T], point: T ): seq[T] =
    ## Returns the points connected to a specific point

    if not group.connections.hasKey(point):
        raise newException(MissingPointError, "Point isnt in group: " & $point)

    return toSeq( items( `[]`(group.connections, point) ) )


