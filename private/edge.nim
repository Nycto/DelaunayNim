#
# Edges
#

import point, tables, sets, optional_t

type EdgeGroup*[T] = object ## \
    ## A group of edges

    # Tracks the bottom-left point in this group of edges
    lowerLeft: Option[T]

    # Tracks the bottom-right point in this group of edges
    lowerRight: Option[T]


type EmptyGroupError* = object of Exception ## \
    ## Thrown when trying to read something out of a group without edges


proc newEdgeGroup*[T: Point](): EdgeGroup[T] =
    ## Creates a new, empty edge group
    result = EdgeGroup[T](
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


proc add*[T] ( group: var EdgeGroup[T], one, two: T ) =
    ## Adds an edge to this group
    group.potentialBottom( one )
    group.potentialBottom( two )

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

