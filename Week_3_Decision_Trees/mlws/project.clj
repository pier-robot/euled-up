(defproject van-challenge "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.0"]]
  :plugins [[lein-cljfmt "0.7.0"] [lein-auto "0.1.3"]]
  :main ^:skip-aot van-challenge.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}}
  :auto {:default {:log-color :green}})
