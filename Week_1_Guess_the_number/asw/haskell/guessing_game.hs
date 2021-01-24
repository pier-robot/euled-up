import Data.Char
import Data.List
import Data.Ord
import System.Random
import Text.Read

lstrip :: String -> String
lstrip xs = dropWhile isSpace xs

rstrip :: String -> String
rstrip xs = dropWhileEnd isSpace xs

strip :: String -> String
strip xs = (rstrip . lstrip) xs

getGuess :: IO (Maybe Int)
getGuess = do
  putStrLn "Please input your guess."
  guess <- getLine
  return $ readMaybe $ strip guess

gameLoop :: Int -> IO ()
gameLoop secretNumber = do
  guess <- getGuess
  case guess of
    Nothing -> gameLoop secretNumber
    Just x -> case compare x secretNumber of
                LT -> (do
                        putStrLn "Too small"
                        gameLoop secretNumber)
                GT -> (do
                        putStrLn "Too big!"
                        gameLoop secretNumber)
                EQ -> (do
                        putStrLn "You win!")

main = do
  putStrLn "Guess the number!"
  gen <- getStdGen
  let (secretNumber, _) = randomR (1, 100) gen
  gameLoop secretNumber
