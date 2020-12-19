library("abind")

stdin <- file("stdin")
lines <- readLines(stdin)
flattened <- unlist(strsplit(lines, "")) == "#"
inp <- array(flattened, dim=c(length(lines), nchar(lines[1])))
close(stdin)

shifter <- function(axis, arr) {
    d <- dim(arr)
    d[axis] <- 1
    array(c(0), dim=d)
}

shift <- function(axis, amt, arr) {
    front <- amt > 0
    amt <- abs(amt)

    if (amt != 0) {
        for (i in 1:amt) {
            if (front) {
                arr <- abind(arr, shifter(axis, arr), along=axis)
            } else {
                arr <- abind(shifter(axis, arr), arr, along=axis)
            }
        }
    }
    arr
}

center_self <- function(arr) {
    arr <- shift(1,  1, arr)
    arr <- shift(1, -1, arr)
    arr <- shift(2,  1, arr)
    arr <- shift(2, -1, arr)
    arr <- shift(3,  1, arr)
    arr <- shift(3, -1, arr)
    arr <- shift(4,  1, arr)
    arr <- shift(4, -1, arr)
    arr
}

sum_neighbours <- function(arr) {
    sum <- 0
    for (xsh in 0:2) {
        for (ysh in 0:2) {
            for (zsh in 0:2) {
                for (wsh in 0:2) {
                    if (all(1 == c(xsh, ysh, zsh, wsh))) next

                    res <- arr
                    res <- shift(1, xsh    , res)
                    res <- shift(1, xsh - 2, res)
                    res <- shift(2, ysh    , res)
                    res <- shift(2, ysh - 2, res)
                    res <- shift(3, zsh    , res)
                    res <- shift(3, zsh - 2, res)
                    res <- shift(4, wsh    , res)
                    res <- shift(4, wsh - 2, res)

                    sum <- sum + res
                }
            }
        }
    }

    sum
}

step <- function(arr) {
    a2a <- center_self(arr) * sum_neighbours(arr)
    a2a <- (a2a >= 2) * (a2a <= 3)
    i2a <- (1 - center_self(arr)) * sum_neighbours(arr)
    i2a <- i2a == 3
    a2a + i2a
}

inp <- step(inp)
inp <- step(inp)
inp <- step(inp)
inp <- step(inp)
inp <- step(inp)
inp <- step(inp)
sum(inp)
