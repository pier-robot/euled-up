(ns van-challenge.core
  (:require [van-challenge.sync-conc :as sc])
  (:gen-class))

(defn -main
  [& args]
  (sc/main args))