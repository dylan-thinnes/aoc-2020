        .data
content: .space 101 # Allow for lines up to 100 chars in length
newline: .asciiz  "\n"
boop:    .asciiz  "boop\n"
space:   .asciiz  " "
        .text
        .globl main

# Read a line from stdin, terminated w/ \n or \0
readline:
        la   $t0, content # Clear character

readline_loop:
        li   $v0, 8
        addi $a0, $t0, 0
        li   $a1, 2
        syscall

        lb   $t1, 0($t0)

        li   $t2, 10
        beq  $t1, $t2, readline_end

        li   $t2, 0
        beq  $t1, $t2, readline_end

        addi $t0, 1
        j    readline_loop

readline_end:
        jr   $ra

# Parse int from a string pointed to by $a
# Return the int in $v0, the position 1 past the end of the parse
parse_int:
        li   $t3, 0
        addi $t4, $a0, 0

parse_int_loop:
        lb   $t0, 0($t4)

        addi $t1, $t0, -47
        blez $t1, parse_int_end
        addi $t1, $t0, -58
        bgtz $t1, parse_int_end

        li   $t2, 10
        multu $t3, $t2
        mflo $t3

        addi $t0, $t0, -48
        add  $t3, $t3, $t0

        addi $t4, $t4, 1

        j    parse_int_loop

parse_int_end:
        addi $v0, $t3, 0
        addi $v1, $t4, 0
        jr   $ra

# Validate a0 (min), a1 (max), a2 (char), a3 (password) according to problem 1
# Return 0 or 1 in v0
validate1:
        # Save all arguments to temporaries
        # Useful if we need to make subroutine calls, e.g. syscall debugging
        addi $t0, $a0, 0
        addi $t1, $a1, 0
        addi $t2, $a2, 0
        addi $t3, $a3, 0

        # Counter for occurrences
        li   $t4, 0

validate1_loop:
        # Load string head
        lb   $t5, 0($t3)

        # If null, end loop
        li   $t6, 0
        beq  $t5, $t6, validate1_loop_end

        # If head matches check character, add 1 to counter
        bne  $t5, $t2, validate1_loop_check_char_no_match
        addi $t4, $t4, 1

validate1_loop_check_char_no_match:
        # Go to next character, loop
        addi $t3, $t3, 1
        j    validate1_loop

validate1_loop_end:
        # Check counter ($t4) is within bounds ($t0, $t1)
        sub  $t5, $t0, $t4
        bgtz $t5 validate1_out_bounds
        sub  $t5, $t4, $t1
        bgtz $t5 validate1_out_bounds

        li   $v0, 1
        jr   $ra
validate1_out_bounds:
        li   $v0, 0
        jr   $ra

validate2:
        # Save all arguments to temporaries
        # Useful if we need to make subroutine calls, e.g. syscall debugging
        addi $t0, $a0, 0
        addi $t1, $a1, 0
        addi $t2, $a2, 0
        addi $t3, $a3, -1 # Decrement string start s.t. position is properly calculated

        # Initialize "counter"
        li   $t4, 0

        # Get character at "min" position
        add  $t5, $t3, $t0
        lb   $t5, 0($t5)

        # If char matches, xor 1 w/ counter
        bne  $t2, $t5, validate2_min_char_invalid
        li   $t4, 1

validate2_min_char_invalid:
        # Get character at "max" position
        add  $t5, $t3, $t1
        lb   $t5, 0($t5)

        # If char matches, xor 1 w/ counter
        bne  $t2, $t5, validate2_max_char_invalid
        xori $t4, $t4, 1

validate2_max_char_invalid:
        addi $v0, $t4, 0
        jr   $ra

main:
        # Read whole line until newline
        jal  readline

        # Print line
        li   $v0, 4
        la   $a0, content
        syscall

        # If the new line contains nothing, abort
        lb   $t0, content
        li   $t1, 0
        beq  $t0, $t1, end

        # Load beginning of string, parse int into s0
        la   $a0, content
        jal  parse_int
        addi $s0, $v0, 0

        # Pick up where last parse finished, plus 1
        # Parse int into s1
        addi $a0, $v1, 1
        jal  parse_int
        addi $s1, $v0, 0

        # Lookup character at (end of second int + 1) into s2
        # This is our "passcheck char"
        addi $s2, $v1, 1
        lb   $s2, 0($s2)

        # String at (end of second int + 4) is password, store into s3
        addi $s3, $v1, 4

        # Print s0, min
        li   $v0, 1
        addi $a0, $s0, 0
        syscall

        li   $v0, 4
        la   $a0, space
        syscall

        # Print s1, max
        li   $v0, 1
        addi $a0, $s1, 0
        syscall

        li   $v0, 4
        la   $a0, space
        syscall

        # Print s2, character code
        li   $v0, 1
        addi $a0, $s2, 0
        syscall

        li   $v0, 4
        la   $a0, space
        syscall

        # Print s3, string
        li   $v0, 4
        addi $a0, $s3, 0
        syscall

        li   $v0, 4
        la   $a0, space
        syscall

        # Validate the input for problem 1
        addi $a0, $s0, 0
        addi $a1, $s1, 0
        addi $a2, $s2, 0
        addi $a3, $s3, 0

        jal validate1

        # Add the result (0 | 1) to s4, the problem 1 counter
        add  $s4, $s4, $v0

        # Log the result (0 | 1)
        addi $a0, $v0, 0
        li   $v0, 1
        syscall

        li   $v0, 4
        la   $a0, newline
        syscall

        # Validate the input for problem 2
        addi $a0, $s0, 0
        addi $a1, $s1, 0
        addi $a2, $s2, 0
        addi $a3, $s3, 0

        jal validate2

        # Add the result (0 | 1) to s5, the problem 2 counter
        add  $s5, $s5, $v0

        # Log the result (0 | 1)
        addi $a0, $v0, 0
        li   $v0, 1
        syscall

        li   $v0, 4
        la   $a0, newline
        syscall

        j main

end:
        # Log the total for problem 1
        li   $v0, 1
        addi $a0, $s4, 0
        syscall

        li   $v0, 4
        la   $a0, newline
        syscall

        # Log the total for problem 2
        li   $v0, 1
        addi $a0, $s5, 0
        syscall

        li   $v0, 4
        la   $a0, newline
        syscall

        # Exit
        li   $v0, 10
        syscall
