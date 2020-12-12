-- Types for agreement between import and self
let types = ./types.dhall
let N = types.Compass.N
let E = types.Compass.E
let S = types.Compass.S
let W = types.Compass.W

-- Boolean negation
let not = \(bool : Bool) -> bool != True

-- Rotation of compass directions
let rot =
    \(dir : types.Compass) -> \(degrees : Natural) ->
        if not (Natural/isZero (Natural/subtract degrees 91))
        then merge { N = E, E = S, S = W, W = N } dir
        else if not (Natural/isZero (Natural/subtract degrees 181))
        then merge { N = S, E = W, S = N, W = E } dir
        else if not (Natural/isZero (Natural/subtract degrees 271))
        then merge { N = W, E = N, S = E, W = S } dir
        else dir

let crot =
    \(compass : types.Compass) -> \(degrees : Natural) ->
        rot compass (Natural/subtract degrees 360)

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
let fromNat = \(n : Natural) -> { neg = False, val = n }

-- Ship definition
let Ship = { dir : types.Compass, x : Signed, y : Signed }
let initialShip = { dir = types.Compass.E, x = fromNat 0, y = fromNat 0 }

-- Run a ship computer instruction
let runInstr =
    \(instr : types.Instr) -> \(ship : Ship) ->
        merge
            { C = \(c : types.Compass) ->
                merge
                    { N = ship with y = add ship.y (fromNat instr.distance)
                    , E = ship with x = add ship.x (fromNat instr.distance)
                    , S = ship with y = sub ship.y (fromNat instr.distance)
                    , W = ship with x = sub ship.x (fromNat instr.distance)
                    }
                    c
            , L = ship with dir = crot ship.dir instr.distance
            , R = ship with dir = rot ship.dir instr.distance
            , F =
                merge
                    { N = ship with y = add ship.y (fromNat instr.distance)
                    , E = ship with x = add ship.x (fromNat instr.distance)
                    , S = ship with y = sub ship.y (fromNat instr.distance)
                    , W = ship with x = sub ship.x (fromNat instr.distance)
                    }
                    ship.dir
            }
            instr.op

let sol1Ship =
    List/fold
        types.Instr
        (List/reverse types.Instr /dev/stdin)
        Ship
        runInstr
        initialShip

let sol1 = sol1Ship.x.val + sol1Ship.y.val

in
--{ types = types, rot = rot, crot = crot }
sol1
