module Day3.Sol where

import Data.Array
import Linear.V2
import Linear.Vector

main = do
    contents <- getContents
    let ls = lines contents
        height = length ls
        width = length $ head ls
        arr = array (V2 0 0, V2 width height)
            $ do
                (l, y) <- zip ls [0..]
                (v, x) <- zip l [0..]
                pure (V2 x y, v == '#')
    print $ sol2 arr

sol1 = count (V2 3 1)
sol2 arr = count (V2 1 1) arr * count (V2 3 1) arr * count (V2 5 1) arr * count (V2 7 1) arr * count (V2 1 2) arr

type Map = Array (V2 Int) Bool

x = fst
y = snd

count :: V2 Int -> Map -> Int
count slope@(V2 right down) arr =
    let (_, V2 width height) = bounds arr
        mult = height `div` down
        indices = map (\(V2 x y) -> V2 (x `mod` width) y) $ map (slope ^*) [0..mult-1]
    in
    length $ filter (arr !) indices
