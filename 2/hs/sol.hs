{-# LANGUAGE RecordWildCards #-}
module Main where

import Data.Char (isDigit)

main = do
    ls <- lines <$> getContents
    print $ sol2 $ map parse ls

sol1 = length . filter valid1
sol2 = length . filter valid2

data Spec = Spec
    { password :: String
    , char :: Char
    , lower :: Int
    , upper :: Int
    }
    deriving (Show)

parse str =
    let [boundsStr, charStr, password] = words str
        lower = read $ takeWhile isDigit boundsStr
        upper = read $ tail $ dropWhile isDigit boundsStr
        char = head charStr
    in
    Spec password char lower upper

valid1 :: Spec -> Bool
valid1 Spec{..} =
    let len = length $ filter (== char) password
    in
    len >= lower && len <= upper

valid2 :: Spec -> Bool
valid2 Spec{..} =
    (== 1) $ length $ filter (== char) [password !! pred lower, password !! pred upper]
