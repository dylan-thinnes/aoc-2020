let Compass = < N | E | S | W >
let Op = < C : Compass | L | R | F >
let Instr = { op : Op, distance : Natural }
in
{ Compass = Compass, Op = Op, Instr = Instr }
