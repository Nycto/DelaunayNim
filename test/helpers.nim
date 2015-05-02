#
# Helpers to make testing easier
#

import sequtils

proc `==`*[T]( actual: seq[T], expected: openArray[T] ): bool =
    ## Allows you to compare a sequence to an array
    result = system.`==`( actual, @expected )

