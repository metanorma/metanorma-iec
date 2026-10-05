Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec
gem "relaton-render", path: "/Users/mulgogi/src/relaton/relaton-render" # TEMP: port validation

gem "metanorma-core", github: "metanorma/metanorma-core", branch: "feat/flavor-table"
# main carries the CitationStyle port: no lib/relaton load paths, so the
# relaton-render facade autoload cannot be stolen at boot
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"

# TEMPORARY: cross-PR branch pins so CI can resolve the in-flight
# metanorma-standoc namespace rename (Metanorma::Standoc::Document)
# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/move-standard-document"
gem "metanorma-document", github: "metanorma/metanorma-document", branch: "feat/model-validation-l1-declarations"
gem "isodoc", github: "metanorma/isodoc", branch: "main" # relaton-render range #846
gem "relaton-cli", ">= 3.0.0.pre.alpha.1"
# Pin relaton: Its VERSION is the cache grammar_hash and it ships the ITU
# scraper. A floating `>= 3.0.0.pre.alpha.1` (via metanorma-document) lets
# CI resolve a newer pre-release, which wipes the vendored spec cache and
# rewrites fixtures against live www.itu.int.
gem "relaton", "3.0.0.pre.alpha.1"
# pubid resolves from the gemspec (~> 2.0.0.pre.alpha); the IEC
# house-style language join (pubid#491/#492) needs >= 2.0.0.pre.alpha.27

eval_gemfile("Gemfile.devel") rescue nil
