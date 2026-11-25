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
gem "metanorma-plugin-lutaml", "~> 0.7"
gem "metanorma-utils", "~> 2.0" # GcBudget
# relaton's VERSION is the cache grammar_hash and it ships the ITU scraper.
# pubid resolves from the gemspec (~> 2.0.0.pre.alpha); the IEC
# house-style language join (pubid#491/#492) needs >= 2.0.0.pre.alpha.27

gem "metanorma-core", git: "https://github.com/metanorma/metanorma-core.git",
    ref: "231ea6e236a6ccb199ff236df675b6a1edc0240a"
gem "metanorma-taste", git: "https://github.com/metanorma/metanorma-taste.git",
    ref: "d0c26613f78bf44fb10c07290b38b7e87aeaf544"
# Native presentation (metanorma-iso#1858): pinned to its head until it merges
gem "metanorma-iso", github: "metanorma/metanorma-iso",
    ref: "1c21c36e935c8a7d0681214aa821b5497877d9cf"
gem "metanorma-ladl", git: "https://github.com/metanorma/metanorma-ladl.git",
    ref: "361b29106e7dd7ffa753e0e35b097cd0cbf622f5"
gem "amath", "= 0.2.0"
gem "bigdecimal", "= 3.3.1"

gem "metanorma-standoc", git: "https://github.com/metanorma/metanorma-standoc.git",
    ref: "38133f98ab62f5bcbc93851b6b06792f49239c71"
gem "metanorma-document", git: "https://github.com/metanorma/metanorma-document.git",
    ref: "3911acbb4ce9d8497a94579610a42d663b8a78cd"
gem "isodoc", "~> 3.7.4"
gem "pubid", "~> 2.0"

eval_gemfile("Gemfile.devel") rescue nil
