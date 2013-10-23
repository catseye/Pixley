import System.Environment

import Pixley

main = do
    [fileName] <- getArgs
    programText <- readFile fileName
    putStrLn (runPixley programText)
