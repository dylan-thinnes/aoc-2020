{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE LambdaCase #-}
module Main where

import Data.Char
import Data.List
import Data.Array
import Prelude hiding (id)
import Control.Monad
import Debug.Trace

main = do
    inp <- getContents
    let (rules, inputs) = parseRulesInputs inp
    print $ length $ filter (hasMatch rules) inputs
    pure ()

split :: Char -> String -> [String]
split sep "" = []
split sep str = takeWhile (/= sep) str : split sep (idTail $ dropWhile (/= sep) str)
    where
        idTail [] = []
        idTail (x:xs) = xs

-- STRUCTURES
type Rules = Array Int Rule
type Inputs = [String]

data Rule = Rule { id :: Int, matches :: [Matcher] }
    deriving (Show, Eq, Ord)

data Matcher
    = Base String
    | Rec [Int]
    deriving (Show, Eq, Ord)

hasMatch :: Rules -> String -> Bool
hasMatch rules = any null . match rules (rules ! 0)

match :: Rules -> Rule -> String -> [String]
match rules rule@(Rule {..}) rem = do
    flip concatMap matches $ \case
      Base str -> do
          guard $ str `isPrefixOf` rem
          pure $ drop (length str) rem
      Rec ids -> do
          let f prevRemainders id =
                  prevRemainders >>= match rules (rules ! id)
          foldl f [rem] ids

-- PARSING
parseRulesInputs :: String -> (Rules, Inputs)
parseRulesInputs str =
    let ls = lines str
        ruleLines = takeWhile (not . null) ls
        inputLines = tail $ dropWhile (not . null) ls

        ruleList = parseRule <$> ruleLines
        rules = array (0, maximum $ id <$> ruleList) ((\rule -> (id rule, rule)) <$> ruleList)

        inputs = inputLines
    in
    (rules, inputs)

parseRule :: String -> Rule
parseRule line =
    let id = read $ takeWhile isDigit line
        rest = drop 2 $ dropWhile isDigit line
        matchStrs = split '|' rest
    in
    Rule id $ parseMatcher <$> matchStrs

parseMatcher :: String -> Matcher
parseMatcher str =
    case filter (not . null) (words str) of
      ['"':rest] -> Base $ init rest
      xs         -> Rec $ map read xs
