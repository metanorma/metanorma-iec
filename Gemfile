source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}" }

gemspec

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
# pubid resolves from the gemspec (~> 2.0.0.pre.alpha); the IEC
# house-style language join (pubid#491/#492) needs >= 2.0.0.pre.alpha.27

gem "metanorma-core", "~> 0.2.7" # published flavor/taste table (metanorma-core#18)
gem "metanorma-iso", ">= 3.5.31"

gem "metanorma-standoc", "~> 3.5.7" # Standoc::Document rename
gem "metanorma-document", "~> 0.5.4"
gem "isodoc", "~> 3.7.4"
gem "pubid", "~> 2.0"

# Native Collection consolidation is needed for bilingual title groups
# (lutaml-model#1174, released in 0.8.182).
gem "lutaml-model", ">= 0.8.182"

eval_gemfile("Gemfile.devel") rescue nil
