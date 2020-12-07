package main

import (
    "fmt"
    "bufio"
    "os"
)

func to_bits(inp *string, bits *int) {
    for i := 0; i < len(*inp) - 1; i++ {
        *bits |= 1 << ((*inp)[i] - 97)
    }
}

func main() {
    var person = 0
    var found = 0xffffffff
    var total int

    reader := bufio.NewReader(os.Stdin)

    for {
        inp, err := reader.ReadString('\n')

        fmt.Printf("%s", inp)
        if len(inp) > 1 && err == nil {
            person = 0
            to_bits(&inp, &person)
            fmt.Printf("%s\n", "zyxwvutsrqponmlkjihgfedcba")
            fmt.Printf("%26b\n", person)
            found &= person
        } else {
            fmt.Printf("%s\n", "===")
            fmt.Printf("%s\n", "zyxwvutsrqponmlkjihgfedcba")
            fmt.Printf("%26b\n", found)
            fmt.Printf("%s\n", "===")

            for i := 0; i < 26; i++ {
                total += found & 1
                found >>= 1
            }

            found = 0xffffffff

            if err != nil {
                fmt.Println("err: ", err)
                break
            }
        }
    }

    fmt.Printf("%d\n", total)
}
