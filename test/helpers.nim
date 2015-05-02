#
# Helpers to make testing easier
#

import sequtils

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

