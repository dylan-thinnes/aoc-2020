-- Types for agreement between import and self
let types = ./types.dhall
let N = types.Compass.N
let E = types.Compass.E
let S = types.Compass.S
let W = types.Compass.W

-- Boolean negation
let not = \(bool : Bool) -> bool != True

-- Signed numbers w/ addition & subtraction
let Signed = { neg : Bool, val : Natural }
let add =
    \(a : Signed) -> \(b : Signed) ->
        if a.neg == b.neg
            then { neg = a.neg, val = a.val + b.val }
            else if Natural/isZero (Natural/subtract b.val a.val)
                  then { neg = b.neg, val = Natural/subtract a.val b.val }
                  else { neg = a.neg, val = Natural/subtract b.val a.val }
let sub =
    \(a : Signed) -> \(b : Signed) ->
        add a (b // { neg = not b.neg })
let times =
    \(a : Signed) -> \(b : Signed) ->
        { neg = a.neg == b.neg, val = a.val * b.val }
let negate =
    \(a : Signed) ->
        a with neg = not a.neg
let fromNat = \(n : Natural) -> { neg = False, val = n }

-- Position
let Pos = { x : Signed, y : Signed }

-- Rotation of positions
let rot =
    \(pos : Pos) -> \(degrees : Natural) ->
        if not (Natural/isZero (Natural/subtract degrees 91))
        then { x = pos.y, y = negate pos.x }
        else if not (Natural/isZero (Natural/subtract degrees 181))
        then { x = negate pos.x, y = negate pos.y }
        else if not (Natural/isZero (Natural/subtract degrees 271))
        then { x = negate pos.y, y = pos.x }
        else pos

let crot =
    \(compass : Pos) -> \(degrees : Natural) ->
        rot compass (Natural/subtract degrees 360)

let addPos =
    \(a : Pos) -> \(b : Pos) ->
        { x = add a.x b.x, y = add a.y b.y }

let timesPos =
    \(a : Pos) -> \(n : Signed) ->
        { x = times a.x n, y = times a.y n }

-- Waypoint & ship definition
let Waypoint = Pos
let Ship = Pos
let initialWaypoint = { x = fromNat 10, y = fromNat 1 }
let initialShip = { x = fromNat 0, y = fromNat 0 }
let State = { waypoint : Waypoint, ship : Ship }
let initialState = { waypoint = initialWaypoint, ship = initialShip }

-- Run a ship computer instruction
let runInstr =
    \(instr : types.Instr) -> \(state : State) ->
        merge
            { C = \(c : types.Compass) ->
                merge
                    { N = state with waypoint.y = add state.waypoint.y (fromNat instr.distance)
                    , E = state with waypoint.x = add state.waypoint.x (fromNat instr.distance)
                    , S = state with waypoint.y = sub state.waypoint.y (fromNat instr.distance)
                    , W = state with waypoint.x = sub state.waypoint.x (fromNat instr.distance)
                    }
                    c
            , L = state with waypoint = crot state.waypoint instr.distance
            , R = state with waypoint = rot state.waypoint instr.distance
            , F = state with ship = addPos state.ship (timesPos state.waypoint (fromNat instr.distance))
            }
            instr.op

let sol2State =
    List/fold
        types.Instr
        (List/reverse types.Instr /dev/stdin)
        State
        runInstr
        initialState

let sol2 = sol2State.ship.x.val + sol2State.ship.y.val

in
-- { rot, crot, fromNat }
{ sol2, sol2State }
