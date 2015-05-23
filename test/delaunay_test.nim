import unittest, helpers, sets, sequtils
import delaunay


suite "Delaunay triangulation should ":
    let emptyEdges: seq[tuple[a, b: tuple[x, y: float]]] = @[]

    test "Return empty for empty input":
        let emptyPoints: seq[tuple[x, y: float]] = @[]
        let edges = toSeq(triangulate(emptyPoints))
        require( edges == emptyEdges )

    test "Return empty for a single point":
        let edges = toSeq( triangulate(@[ p(1, 1) ]) )
        require( edges == emptyEdges )

    test "Return a single edge with two points":
        let expected = edges( p(1, 1) -> p(4, 4) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Return three edges for a triangle":
        let expected = edges(
            p(0, 0) -> p(2, 2), p(0, 0) -> p(4, 0), p(2, 2) -> p(4, 0) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Return two edges for a line":
        block:
            let expected = edges( p(0, 0) -> p(2, 2), p(2, 2) -> p(4, 4) )
            let triangulated = toSeq(triangulate(@[p(0, 0), p(2, 2), p(4, 4)]))
            require( expected == triangulated )

        block:
            let expected = edges( p(0, 0) -> p(2, 2), p(2, 2) -> p(4, 4) )
            let triangulated = toSeq(triangulate(@[p(0, 0), p(4, 4), p(2, 2)]))
            require( expected == triangulated )

        block:
            let expected = edges( p(0, 0) -> p(2, 2), p(2, 2) -> p(4, 4)  )
            let triangulated = toSeq(triangulate(@[p(4, 4), p(0, 0), p(2, 2) ]))
            require( expected == triangulated )

    test "Four points":
        # Edges for the following grid:
        #
        # 2 |    *
        # 1 | *        *
        # 0 |    *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(0, 1) -> p(1, 0), p(0, 1) -> p(1, 2),
            p(1, 0) -> p(1, 2), p(1, 0) -> p(3, 1),
            p(1, 2) -> p(3, 1) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "One Merge":
        # Edges for the following grid:
        #
        # 3 |    *
        # 2 |    *
        # 1 | *     *
        # 0 |    *
        #   ----------
        #     0  1  2

        let expected = edges(
            p(0, 1) -> p(1, 0), p(0, 1) -> p(1, 2), p(0, 1) -> p(1, 3),
            p(1, 0) -> p(2, 1), p(1, 0) -> p(1, 2),
            p(1, 2) -> p(2, 1), p(1, 2) -> p(1, 3),
            p(1, 3) -> p(2, 1) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Right half of the complex grid":
        # Edges for the following grid:
        #
        # 3 |          *     *
        # 2 |             *
        # 1 |                *
        # 0 |                *
        #   -------------------
        #     0  1  2  3  4  5

        let expected = edges(
            p(3, 3) -> p(5, 0), p(3, 3) -> p(4, 2), p(3, 3) -> p(5, 3),
            p(4, 2) -> p(5, 0), p(4, 2) -> p(5, 1), p(4, 2) -> p(5, 3),
            p(5, 0) -> p(5, 1),
            p(5, 1) -> p(5, 3) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Complex grid":
        # Edges for the following grid:
        #
        # 3 |    *     *     *
        # 2 |    *        *
        # 1 | *     *        *
        # 0 |    *           *
        #   -------------------
        #     0  1  2  3  4  5

        let expected = edges(
            p(0, 1) -> p(1, 0), p(0, 1) -> p(1, 2), p(0, 1) -> p(1, 3),
            p(1, 0) -> p(1, 2), p(1, 0) -> p(2, 1), p(1, 0) -> p(5, 0),
            p(1, 2) -> p(2, 1), p(1, 2) -> p(3, 3), p(1, 2) -> p(1, 3),
            p(1, 3) -> p(3, 3),
            p(2, 1) -> p(5, 0), p(2, 1) -> p(4, 2), p(2, 1) -> p(3, 3),
            p(3, 3) -> p(4, 2), p(3, 3) -> p(5, 3),
            p(4, 2) -> p(5, 0), p(4, 2) -> p(5, 1), p(4, 2) -> p(5, 3),
            p(5, 0) -> p(5, 1),
            p(5, 1) -> p(5, 3) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Left higher than right":
        # Edges for the following grid:
        #
        # 2 | *  *
        # 1 |
        # 0 |       *  *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(0, 2) -> p(1, 2), p(0, 2) -> p(2, 0),
            p(1, 2) -> p(2, 0), p(1, 2) -> p(3, 0),
            p(2, 0) -> p(3, 0) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Tie for bottom":
        ## Edges for the following grid:
        ##
        ## 2 |       *  *  *
        ## 1 |
        ## 0 | *  *  *
        ##   ----------------
        ##     0  1  2  3  4

        let expected = edges(
            p(0, 0) -> p(1, 0), p(0, 0) -> p(2, 2),
            p(1, 0) -> p(2, 0), p(1, 0) -> p(2, 2),
            p(2, 0) -> p(2, 2), p(2, 0) -> p(3, 2), p(2, 0) -> p(4, 2),
            p(2, 2) -> p(3, 2),
            p(3, 2) -> p(4, 2) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Horizontal grid":
        # Edges for the following grid:
        #
        # 0 | *  *  *  *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(0, 0) -> p(1, 0),
            p(1, 0) -> p(2, 0),
            p(2, 0) -> p(3, 0) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Right higher than left":
        # Edges for the following grid:
        #
        # 2 |       *  *
        # 1 |
        # 0 | *  *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(0, 0) -> p(1, 0), p(0, 0) -> p(2, 2),
            p(1, 0) -> p(2, 2), p(1, 0) -> p(3, 2),
            p(2, 2) -> p(3, 2) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Deceptive base edge":
        # Edges for the following grid:
        #
        # 2 | *     *
        # 1 | *
        # 0 | *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(0, 0) -> p(0, 1), p(0, 0) -> p(2, 2),
            p(0, 1) -> p(0, 2), p(0, 1) -> p(2, 2),
            p(0, 2) -> p(2, 2) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Merge from non-bottom":

        # Edges for the following grid:
        #
        # 3 |             *
        # 2 |       *
        # 1 |       *
        # 0 | *
        #   ----------------
        #     0  1  2  3  4

        let expected = edges(
            p(0, 0) -> p(2, 1), p(0, 0) -> p(2, 2),
            p(2, 1) -> p(2, 2), p(2, 1) -> p(4, 3),
            p(2, 2) -> p(4, 3) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Reconsider right base edge":
        # Edges for the following grid:
        #
        # 4 |             *
        # 3 |
        # 2 |          *
        # 1 |          *
        # 0 | *
        #   ----------------
        #     0  1  2  3  4

        let expected = edges(
            p(0, 0) -> p(3, 1), p(0, 0) -> p(3, 2), p(0, 0) -> p(4, 4),
            p(3, 1) -> p(3, 2), p(3, 1) -> p(4, 4),
            p(3, 2) -> p(4, 4) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Vertical line":
        # Edges for the following grid:
        #
        # 3 |    *
        # 2 |    *
        # 1 |    *
        # 0 |    *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(1, 0) -> p(1, 1),
            p(1, 1) -> p(1, 2),
            p(1, 2) -> p(1, 3) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )

    test "Diagonal line":
        # Edges for the following grid:
        #
        # 3 |          *
        # 2 |       *
        # 1 |    *
        # 0 | *
        #   -------------
        #     0  1  2  3

        let expected = edges(
            p(0, 0) -> p(1, 1),
            p(1, 1) -> p(2, 2),
            p(2, 2) -> p(3, 3) )
        let triangulated = triangulate(expected)
        require( expected == triangulated )


