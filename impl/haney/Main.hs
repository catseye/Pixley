import System.Environment

import Pixley

main = do
    [fileName] <- getArgs
    programText <- readFile fileName
    putStrLn $ show $ runPixley programText
