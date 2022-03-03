import System.Random
import Text.Read (readMaybe)
import Data.Char (isDigit)


data Peano = Zero | Succ Peano deriving Show

-- Defines an equivalence relation on Peano numbers.
instance Eq Peano where
    Zero == Zero         = True
    Zero == (Succ _)     = False
    (Succ _) == Zero     = False
    (Succ n) == (Succ m) = n == m


-- Defines a total ordering on Peano numbers.
instance Ord Peano where
    compare Zero Zero         = EQ
    compare (Succ _) Zero     = GT
    compare Zero (Succ _)     = LT
    compare (Succ n) (Succ m) = compare n m


-- Allows the conversion of a string like "12" to a Peano number.
-- Note that this will fail to read a number with a sign (+/-) in front.
instance Read Peano where
    readsPrec _ input = parse (words input) 
        where
            parse [word] = [(toPeano (read word::Int), "") | all isDigit word]
            parse _ = []


-- Implements the generation of random Peano values.
instance Random Peano where
    -- Instead of coming up with our own random number generator,
    -- we are essentially stealing the Integer instance and repurposing it.
    randomR (lowerBound, upperBound) g = 
        let (a, g') = randomR (fromPeano lowerBound, fromPeano upperBound) g
        in (toPeano a, g')

    -- 100 was arbitrarily chosen as the upper bound, to prevent a neverending cascade
    -- of Succ (Succ (Succ (Succ ... ad infinitum
    random = randomR (Zero, toPeano 100)


-- Convert an integer to a Peano number.
toPeano :: (Integral a) => a -> Peano
toPeano 0 = Zero
toPeano n
    | n < 0     = error "Can't convert a negative number to a Peano number."
    | otherwise = Succ $ toPeano (n - 1)


-- Convert a Peano number to an Integer.
fromPeano :: Peano -> Integer
fromPeano Zero     = 0
fromPeano (Succ n) = (+) 1 $ fromPeano n


-- Get an integer between 1 and 10 from the user, and convert to Peano.
getGuess :: IO Peano
getGuess = do
    putStr "Pick a number: "
    guess <- getLine
    case readMaybe guess of
        Just x -> 
            if x >= (1::Peano) && x <= (10::Peano) then 
                return x
            else
                putStrLn "I said between 1 and 10!" >> getGuess
        Nothing -> putStrLn "That's not a number, try again!" >> getGuess


-- Game logic.
guessingGame :: Peano -> IO ()
guessingGame answer = do
    guess <- getGuess
    case compare guess answer of
        LT -> putStrLn "Too low..." >> guessingGame answer
        GT -> putStrLn "Too high..." >> guessingGame answer
        EQ -> putStrLn "Well done, you got it!"


-- Entry point for the program.
main :: IO ()
main = do
    rng <- getStdGen
    let (answer, _) = randomR (1::Peano, 10::Peano) rng
    putStrLn "I'm thinking of a number between 1 and 10..."
    guessingGame answer


-- Implements arithmetic for Peano numbers.
-- Note the only part of this that's actually being used is fromInteger,
-- which lets us declare numbers as having type Peano, e.g. let x = 5::Peano.
instance Num Peano where
    -- Addition.
    Zero + n            = n
    n + Zero            = n
    (Succ n) + (Succ m) = Succ $ Succ $ n + m

    -- Subtraction.
    Zero - n            = Zero
    n - Zero            = n
    (Succ n) - (Succ m) = n - m

    -- Multiplication.
    Zero * n     = Zero
    n * Zero     = Zero
    n * (Succ m) = n + (n * m)

    -- Absolute value.
    abs = id
    
    -- Sign of a number. For real numbers, 1 indicates positive.
    signum _ = Succ Zero

    -- Conversion from Integers.
    fromInteger = toPeano
