source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec
gem "relaton-render", "~> 3.0"

# main carries the CitationStyle port: no lib/relaton load paths, so the
# relaton-render facade autoload cannot be stolen at boot

# TEMPORARY: cross-PR branch pins so CI can resolve the in-flight
# metanorma-standoc namespace rename (Metanorma::Standoc::Document)
# and the pubid-2 / relaton-bib 2.2 / metanorma-document 0.5 chain.
# Revert each pin once the corresponding PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-document/pull/45
gem "metanorma-plugin-lutaml", github: "metanorma/metanorma-plugin-lutaml", branch: "main" # LutamlDataPreprocessor, unreleased
gem "metanorma-utils", "~> 2.0" # GcBudget
# relaton's VERSION is the cache grammar_hash and it ships the ITU scraper.
gem "relaton", "~> 3.0"
# pubid resolves from the gemspec (~> 2.0.0.pre.alpha); the IEC
# house-style language join (pubid#491/#492) needs >= 2.0.0.pre.alpha.27

gem "metanorma-core", "~> 0.2.5.pre.alpha" # published flavor/taste table (metanorma-core#18)
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "main"

gem "metanorma-standoc", "~> 3.5.1.pre.alpha" # Standoc::Document rename
gem "metanorma-document", "~> 0.5.2.pre.alpha"
gem "isodoc", "~> 3.7.4.pre.alpha"
gem "relaton-cli", "~> 3.0"
gem "pubid", "~> 2.0"

eval_gemfile("Gemfile.devel") rescue nil
