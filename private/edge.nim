#
# Edges
#

import point, tables, sets, optional_t, anglesort, sequtils

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


proc newEdgeGroup*[T: Point](): EdgeGroup[T] =
    ## Creates a new, empty edge group
    result = EdgeGroup[T](
        connections: initTable[T, HashSet[T]](),
        lowerLeft: None[T](),
        lowerRight: None[T]()
    )


proc potentialBottom[T]( group: var EdgeGroup[T], point: T ) =
    ## Compares a point to the bottom most points already tracked. Replaces
    ## those points with this one if this is lower. Adds it if it is on the
    ## same level.

    if isNone(group.lowerLeft) or point.y < group.lowerLeft.get.y:
        group.lowerLeft = Some(point)
        group.lowerRight = Some(point)

    elif point.y == group.lowerLeft.get.y:
        if point.x < group.lowerLeft.get.x:
            group.lowerLeft = Some(point)
        if point.x > group.lowerRight.get.x:
            group.lowerRight = Some(point)

proc connect[T]( group: var EdgeGroup[T], base, other: T ) =
    ## Adds a point and its connection to his group

    if group.connections.hasKey(base):
        group.connections.mget(base).incl(other)
    else:
        group.connections.add(base, toSet([ other ]))


proc add*[T] ( group: var EdgeGroup[T], one, two: T ) =
    ## Adds an edge to this group
    group.potentialBottom( one )
    group.potentialBottom( two )
    group.connect( one, two )
    group.connect( two, one )

proc add*[T] ( group: var EdgeGroup[T], other: EdgeGroup[T] ) =
    ## Adds an entire EdgeGroup to this one
    for point, edges in pairs( other.connections ):
        if group.connections.hasKey(point):
            for other in items( edges ):
                group.connections.mget(point).incl(other)
        else:
            group.connections.add(point, edges)

    if isSome(other.lowerLeft):
        group.potentialBottom( other.lowerLeft.get )

    if isSome(other.lowerRight):
        group.potentialBottom( other.lowerRight.get )


proc remove*[T] ( group: var EdgeGroup[T], one, two: T ) =
    ## Removes an edge from this group. Note that the two points are still
    ## considered as part of this EdgeGroup when considering the bottom left
    ## and bottom right points
    if group.connections.hasKey(one):
        group.connections.mget(one).excl(two)
    if group.connections.hasKey(two):
        group.connections.mget(two).excl(one)

proc bottomRight*[T]( group: EdgeGroup[T] ): T =
    ## Returns the bottom right point in this edge group
    if isNone group.lowerRight:
        raise newException(EmptyGroupError, "EdgeGroup is empty")
    return group.lowerRight.get

proc bottomLeft*[T]( group: EdgeGroup[T] ): T =
    ## Returns the bottom left point in this edge group
    if isNone group.lowerLeft:
        raise newException(EmptyGroupError, "EdgeGroup is empty")
    return group.lowerLeft.get

iterator edges*[T]( group: EdgeGroup[T] ): tuple[a, b: T] =
    ## Iterates over all the edges in a group

    var seen = initSet[T]()
    for key in group.connections.keys:
        seen.incl(key)
        for point in `[]`(group.connections, key).items:
            if not seen.contains(point):
                yield (a: key, b: point)


proc `$`*[T]( group: EdgeGroup[T] ): string =
    ## Creates a readable string from an edge group
    result = "EdgeGroup( "
    var first = true
    for edge in edges( group ):
        if first:
            first = false
        else:
            result.add(", ")
        result.add( "(" & $edge.a.x & ", " & $edge.a.y & ") -> " )
        result.add( "(" & $edge.b.x & ", " & $edge.b.y & ")" )
    result.add(" )")


type MissingPointError* = object of Exception ## \
    ## Thrown when trying to read connections of a point that isn't in a group

iterator connected*[T: Point](
    group: EdgeGroup[T], point: T, sortVersus: T, direction: Direction
): T =
    ## Iterates over the points connected to another point, sorted
    ## relative to `sortVersus`
    if not group.connections.hasKey(point):
        raise newException(MissingPointError, "Point is in group: " & $point)

    # FIXME: This copies the list of points into a sequence, just so that we
    # can iterate over them. It would be nice to just iterate over them
    # directly.
    let points = toSeq( items( `[]`(group.connections, point) ) )

    let sorted = sort( points, direction, point, sortVersus )

    for point in sorted():
        yield point


