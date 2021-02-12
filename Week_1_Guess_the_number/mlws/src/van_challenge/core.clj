(ns van-challenge.core
  (:require [van-challenge.number-game :as number-game])
  (:gen-class))

(defn -main
  [& args]
  (number-game/main))