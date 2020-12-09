module Main where

import qualified Data.Set as S

main = (map read . lines <$> getContents) >>= print . sol2'

sol :: [Int] -> Int
sol inp =
    let diffs = S.fromList $ map (2020 -) inp
        sumTo2020 = diffs `S.intersection` S.fromList inp
        res = S.findMin sumTo2020
    in
    res * (2020 - res)

sol' i=[(a,b,a*b)|a<-i,b<-i,a+b==2020]!!0

sol2' i=[(a,b,c,a*b*c)|a<-i,b<-i,c<-i,a+b+c==2020]!!0
