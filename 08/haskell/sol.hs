module Main where

import           Control.Monad (guard)
import           Data.Array
import qualified Data.Set as S
import           Data.Maybe (mapMaybe, isJust)
import           Data.Function (on)

main :: IO ()
main = do
    Just ops <- parseAll <$> getContents
    let machine = initialize ops
    print $ sol1 machine
    print $ head $ sol2 machine

data Op
  = Nop Int
  | Acc Int
  | Jmp Int
    deriving (Show, Eq, Ord)

parse :: String -> Maybe Op
parse str = do
    [opCode, argStr] <- pure $ words str

    arg <- case argStr of
            '+':rest -> Just $ read rest
            '-':rest -> Just $ negate $ read rest
            _        -> Nothing

    case opCode of
      "nop" -> pure $ Nop arg
      "acc" -> pure $ Acc arg
      "jmp" -> pure $ Jmp arg
      _     -> Nothing

parseAll :: String -> Maybe [Op]
parseAll = mapM parse . lines

type Prog = Array Int Op
data Machine = Machine
    { pc :: Int
    , acc :: Int
    , prog :: Prog
    }
    deriving (Show, Eq, Ord)

halted :: Machine -> Bool
halted = isJust . step

initialize :: [Op] -> Machine
initialize ops = Machine 0 0 $ listArray (0, length ops - 1) ops

runOp :: Op -> Machine -> Machine
runOp op machine =
    case op of
      Nop _   -> machine { pc = pc machine + 1 }
      Acc arg -> machine { acc = acc machine + arg, pc = pc machine + 1 }
      Jmp arg -> machine { pc = pc machine + arg }

step :: Machine -> Maybe Machine
step machine = do
    guard $ pc machine <= snd (bounds (prog machine))
    pure $ runOp (prog machine ! pc machine) machine

run :: Machine -> [Machine]
run machine = case step machine of
                Just next -> machine : run next
                Nothing   -> [machine]

runWithPrevPcs :: Machine -> [(S.Set Int, Machine)]
runWithPrevPcs machine =
    let states = run machine
        prevPcs = scanl (flip S.insert) S.empty (map pc states)
    in
    zip prevPcs states

preloop :: Machine -> [Machine]
preloop machine =
    let states = runWithPrevPcs machine
        seenAlready (pcs, machine) = pc machine `S.member` pcs
    in
    snd <$> takeWhile (not . seenAlready) states

loop :: Machine -> Either [Machine] [Machine]
loop machine =
    let pl = preloop machine
        firstLoopState = step $ last pl
    in
    case firstLoopState of
      Nothing -> Left pl
      Just s  -> Right $ dropWhile (on (/=) pc $ s) pl

sol1 :: Machine -> Int
sol1 = acc . last . preloop

sol2 :: Machine -> [Int]
sol2 machine = do
    (index, op) <- assocs $ prog machine
    guard $ isNopJmp op
    let newMachine = machine { prog = prog machine // [(index, toggleNopJmp op)] }
    Left trace <- pure $ loop newMachine
    pure $ acc $ last trace
    where
        isNopJmp (Jmp _) = True
        isNopJmp (Nop _) = True
        isNopJmp _       = False

        toggleNopJmp (Jmp i) = Nop i
        toggleNopJmp (Nop i) = Jmp i
        toggleNopJmp op      = op
