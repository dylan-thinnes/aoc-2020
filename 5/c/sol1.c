#include <stdio.h>

int to_int (char* str) {
    int res = 0;

    while (*str != '\0') {
        res *= 2;
        res += *str == 'B' || *str == 'R';
        str++;
    }

    return res;
}

int main () {
    int seats[1024] = {};
    int max_seat = 0;

    int seat;
    char inp[11];

    while (1) {
        scanf("%10s\n", inp);
        if (feof(stdin)) break;

        seat = to_int(inp);

        max_seat = seat > max_seat ? seat : max_seat;
        seats[seat] = 1;
    }

    printf("%d\n", max_seat);

    for (int ii = 1; ii < 1023; ii++) {
        if (seats[ii-1] && !seats[ii] && seats[ii+1]) {
            printf("%d\n", ii);
            break;
        }
    }
}
