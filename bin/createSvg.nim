import strutils, delaunay, options

when defined(profiler) or defined(memProfiler):
    import nimprof

proc getOrElse[T]( opt: Option[T], default: T ): T =
    if opt.isSome: opt.get else: default

var points: seq[tuple[x, y: float]] = @[]

var width: float = 0
var height: float = 0
var minX: Option[float] = none(float)
var minY: Option[float] = none(float)

for line in stdin.lines:
    let parts = line.split({' ', ','})

    if parts.len mod 2 != 0:
        stderr.writeLine "Line contains an odd number of inputs:\n" & line
        quit(QuitFailure)

    for i in countup(0, parts.len - 1, 2):
        try:
            let point = (x: parseFloat(parts[i]), y: parseFloat(parts[i + 1]))
            points.add(point)

            # Track the highest and lowest `X` to snug in the viewport
            width = if point.x > width: point.x else: width
            if minY.isNone or point.x < minX.get:
                minX = some(point.x)

            # Track the highest and lowest `Y` to snug in the viewport
            height = if point.y > height: point.y else: height
            if minY.isNone or point.y < minY.get:
                minY = some(point.y)

        except ValueError:
            stderr.writeLine "Point can not be parsed as numbers:\n" & line
            quit(QuitFailure)


echo "<?xml version=\"1.0\"?>"
echo "<svg width=\"$1\" height=\"$2\"" % [
    $(width - minX.getOrElse(0)), $(height - minY.getOrElse(0)) ]
echo "    version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">"

for a, b in triangulate(points):
    echo "  <line x1=\"$1\" y1=\"$2\" x2=\"$3\" y2=\"$4\"" % [
        $(a.x - minX.getOrElse(0)), $(height - a.y),
        $(b.x - minX.getOrElse(0)), $(height - b.y)
    ]
    echo "    stroke=\"black\" stroke-width=\"2\"/>"

echo "</svg>"

