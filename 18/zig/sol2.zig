const std = @import("std");

const Lexeme = union(enum) { value: i64, op: Op, open: void, close: void };
const LexData = struct {
    lexeme: Lexeme, start: u16,
    length: u16,
    fn full_length(self: *LexData) u16 {
        return self.start + self.length;
    }
};

pub fn lexInt (buf: []u8, start: u16) LexData {
    var length: u16 = 0;
    for (buf) |c, i| {
        if (!(c == '-' and i == 0 or '0' <= c and c <= '9')) break;
        length += 1;
    }

    var value: i64 = std.fmt.parseInt(i64, buf[0..length], 10) catch unreachable;

    return LexData{ .start = start, .length = length, .lexeme = Lexeme{ .value = value } };
}

pub fn lex (buf: []u8) ?LexData {
    var start: u16 = 0;
    return while (start < buf.len) {
        switch (buf[start]) {
            '-'       => break lexInt(buf[start..], start),
            '0'...'9' => break lexInt(buf[start..], start),
            '('       => break LexData{ .start = start, .length = 1, .lexeme = Lexeme{ .open = .{} } },
            ')'       => break LexData{ .start = start, .length = 1, .lexeme = Lexeme{ .close = .{} } },
            '*'       => break LexData{ .start = start, .length = 1, .lexeme = Lexeme{ .op = Op.multiply } },
            '+'       => break LexData{ .start = start, .length = 1, .lexeme = Lexeme{ .op = Op.add } },
            else      => {}
        }

        start += 1;
    } else null;
}

const LexemeStream = struct {
    buf: []u8,
    pub fn next (self: *LexemeStream) ?Lexeme {
        // Get lex data, abort if null
        var lex_data: ?LexData = lex(self.buf);
        if (lex_data == null) return null;

        // Slice buf, return lexeme
        self.buf = self.buf[lex_data.?.full_length()..];
        return lex_data.?.lexeme;
    }
};

const Op = enum { multiply, add };
const Stack = struct { val: i64, op: Op, prev: ?*Stack };

pub fn process_stream(lexemes: *LexemeStream, allocator: *std.mem.Allocator) *Stack {
    // Create root stack "frame"
    var stack: *Stack = allocator.create(Stack) catch unreachable;
    stack.* = Stack{ .val = 1, .op = Op.multiply, .prev = null };
    push_stack(&stack, allocator, Op.add);

    var lexeme : ?Lexeme = lexemes.next();
    while (lexeme != null) {
        switch (lexeme.?) {
            .value => |value| apply_val(stack, value),
            .op    => |op|
                switch (op) {
                    Op.add => {},
                    Op.multiply => {
                        pop_stack(&stack);
                        push_stack(&stack, allocator, Op.add);
                    }
                },
            .open  => |_|
                {
                    push_stack(&stack, allocator, Op.multiply);
                    push_stack(&stack, allocator, Op.add);
                },
            .close => |_|
                {
                    pop_stack(&stack);
                    pop_stack(&stack);
                }
        }

        lexeme = lexemes.next();
    }

    pop_stack(&stack);
    return stack;
}

pub fn apply_val(stack: *Stack, val: i64) void {
    switch (stack.*.op) {
        Op.add => { stack.*.val += val; },
        Op.multiply => { stack.*.val *= val; },
    }
}

pub fn update_stack(stack: *Stack, val: i64, op: Op) void {
    switch (stack.*.op) {
        Op.add => { stack.*.val += val; },
        Op.multiply => { stack.*.val *= val; },
    }

    stack.*.op = op;
}

pub fn push_stack(stackp: **Stack, allocator: *std.mem.Allocator, op: Op) void {
    var old_stack: *Stack = stackp.*;
    stackp.* = allocator.*.create(Stack) catch unreachable;

    var identity : i64 = if (op == Op.multiply) 1 else 0;
    stackp.*.* = Stack{ .val = identity, .op = op, .prev = old_stack };
}

pub fn pop_stack(stackp: **Stack) void {
    if (stackp.*.*.prev) |prev| {
        apply_val(prev, stackp.*.val);
        stackp.* = prev;
    } else {
        std.debug.print("Tried to pop a nonexistent stack!", .{});
        std.process.exit(1);
    }
}

pub fn main() void {
    // Stdin reader
    const stdin = std.io.getStdIn();
    defer stdin.close();
    const reader = stdin.reader();

    // Allocator - since memory won't grow w/o bound (input is finite, no
    // unbounded behaviour), use ArenaAllocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = std.heap.ArenaAllocator.init(&gpa.allocator);
    defer allocator.deinit();

    // As long as EOF ain't reached, read lines, parse them, and sum
    var line: []u8 = undefined;
    var sum: i64 = 0;
    while (true) {
        // Read a line
        line =
            reader.readUntilDelimiterOrEofAlloc(&gpa.allocator, '\n', 1000)
            catch {
                std.debug.print("Error reading a line.\n", .{});
                std.process.exit(1);
            };

        if (line.len == 0) break;

        // std.debug.print("Line '{}'\n", .{ line });
        var lexemes : LexemeStream = LexemeStream{ .buf = line };
        var stack : *Stack = process_stream(&lexemes, &gpa.allocator);
        std.debug.print("Result: {}\n", .{ stack.*.val });
        sum += stack.*.val;
    }

    std.debug.print("Sum: {}\n", .{ sum });
}
