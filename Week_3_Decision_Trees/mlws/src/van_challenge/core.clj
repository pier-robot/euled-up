(ns van-challenge.core
  (:require [van-challenge.ttt :as ttt])
  (:gen-class))

(defn -main
  [& args]
  (ttt/main))