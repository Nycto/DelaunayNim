#
# Runs a delaunay triangulation on a set of points
#

import options
import delaunay/private/point
import delaunay/private/edge
import delaunay/private/anglesort
import delaunay/private/triangle


iterator pairIter[T](
    inner: AngleSorted[T]
): tuple[current: T, next: Option[T]] =
    ## Present two points at a time instead of one

    var first = true
    var current: T

    for next in items(inner):
        if first:
            first = false
        else:
            let tup = (current: current, next: some[T](next))
            yield tup

        current = next

    if not first:
        let tup = (current: current, next: none(T))
        yield tup


proc findCandidate[T: Point](
    group: var EdgeGroup[T], anchor: T, reference: T, points: AngleSorted[T]
): Option[T] =
    ## Searches the given list of points for an acceptable candidate for
    ## the next edge

    for point, next in pairIter( points ):
        if next.isNone:
            return some[T](point)

        let triangle = newTriangle(anchor, reference, point)

        # Kill this edge if the next point is in the circumcircle
        if triangle.isInCircumcircle(next.get):
            group.remove(anchor, point)
        else:
            return some(point)

    return none(T)


proc mergeUsingBase[T: Point](
    left: var EdgeGroup[T], right: var EdgeGroup[T],
    baseEdge: tuple[left, right: T]
) =
    ## Merges together two edge groups using the given edge as the
    ## base for the merge

    let leftPoints = sort(
        connected[T](left, baseEdge.left),
        counterclockwise, baseEdge.left, baseEdge.right )

    let leftCandidate = findCandidate(
        left, baseEdge.left, baseEdge.right, leftPoints )

    let rightPoints = sort(
        connected[T](right, baseEdge.right),
        clockwise, baseEdge.right, baseEdge.left )

    let rightCandidate = findCandidate(
        right, baseEdge.right, baseEdge.left, rightPoints)

    left.add( baseEdge.left, baseEdge.right );

    # Without candidates, there is nothing to merge
    if rightCandidate.isNone and leftCandidate.isNone:
        return

    # If there are candidates on the left but not the right
    elif rightCandidate.isNone:
        let newBase = (left: leftCandidate.get, right: baseEdge.right)
        mergeUsingBase[T]( left, right, newBase )
        return

    # If there are candidates on the right but not the left
    elif leftCandidate.isNone:
        let newBase = (left: baseEdge.left, right: rightCandidate.get)
        mergeUsingBase[T]( left, right, newBase )
        return

    let triangle = newTriangle(baseEdge.left, baseEdge.right, leftCandidate.get)

    # If the right candidate is within the circumcircle of the left
    # candidate, then the right candidate is the one we choose
    if triangle.isInCircumcircle(rightCandidate.get):
        let newBase = (left: baseEdge.left, right: rightCandidate.get)
        mergeUsingBase( left, right, newBase )

    # The only remaining option is that the left candidate is the one
    else:
        let newBase = (left: leftCandidate.get, right: baseEdge.right)
        mergeUsingBase[T]( left, right, newBase )

proc chooseBase[T: Point](
    group: EdgeGroup[T], direction: Direction,
    examine: T, reference: T
): T =
    ## Chooses the base point for a new merge from a single group
    ## * direction - The direction to sort pulled edges
    ## * best - The best point seen so far
    ## * examine - The next point to examine
    ## * reference - The reference point from the other side of the merge

    # If we see a horizontal line, both right and left are on even ground
    if reference.y == examine.y:
        return examine

    let connected = sort(
        connected(group, examine),
        direction, examine, reference
    ).first

    # No more options? Guess this is it...
    if connected.isNone:
        return examine
    else:
        return chooseBase( group, direction, connected.get, reference )

proc chooseBases[T: Point](
    left: EdgeGroup[T], right: EdgeGroup[T]
): tuple[left, right: T] =
    ## Chooses base points and invokes a function with them

    let baseRight = chooseBase(
        right, counterclockwise, right.bottomLeft, left.bottomRight)

    let baseLeft = chooseBase(
        left, clockwise, left.bottomRight, baseRight)

    # Walk the right side back towards the right to confirm that we made
    # the correct choice before. This can fix situations where we chose
    # the wrong baseLeft in the first pass
    let verifiedRight = chooseBase(
        right, counterclockwise, baseRight, baseLeft)

    return (left: baseLeft, right: verifiedRight)


proc merge[T: Point](
    left: var EdgeGroup[T], right: var EdgeGroup[T]
): EdgeGroup[T] =
    ## Merges together sets of edges into the left edge
    mergeUsingBase(left, right, chooseBases(left, right))
    left.add(right)
    return left


proc calculate[T: Point]( points: PointList[T] ): EdgeGroup[T] =
    ## Calculates the edges for a list of points

    case points.len
    of 0..1:
        return newEdgeGroup[T]()

    of 2:
        return newEdgeGroup[T]( `[]`(points, 0) -> `[]`(points, 1) )

    of 3:
        let tri = newTriangle(`[]`(points, 0), `[]`(points, 1), `[]`(points, 2))
        let ab = tri.a -> tri.b
        let bc = tri.b -> tri.c

        # If it isn't a triangle, it's a line. And because we can rely on
        # the sort order of a PointList, we know this would be a duplicate
        # edge unless its a triangle
        if tri.isTriangle:
            return newEdgeGroup[T]( ab, bc, (tri.a -> tri.c) )
        else:
            return newEdgeGroup[T]( ab, bc )

    else:
        let (left, right) = points.split
        var leftEdges = calculate(left)
        var rightEdges = calculate(right)
        return merge( leftEdges, rightEdges )


iterator triangulate*[T: Point]( rawPoints: openArray[T] ): tuple[a, b: T] =
    ## Iterates through the edges formed by running a delaunay triangulation
    ## on a set of points
    let points = newPointList(rawPoints)
    for edge in edges( calculate(points) ):
        yield edge

