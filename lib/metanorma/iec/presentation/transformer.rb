# frozen_string_literal: true

require "metanorma/iec/document"
require "metanorma/iso/presentation/transformer"
require "metanorma/ladl"
require "metanorma/ladl/document_adapter"

module Metanorma
  module Iec
    module Presentation
      # Native presentation for IEC. IEC inherits ISO's section model, so the
      # ISO model tree, display projection and unsupported-content guard are
      # reused unchanged; only the typed root and flavor differ.
      #
      # The IEC house style shares ISO's LADL profile (iso_iec), so when the
      # caller supplies no :document_labeler that profile is used.
      class Transformer < Metanorma::Iso::Presentation::Transformer
        def call(semantic_root, flavor:, options:)
          check_input!(semantic_root, flavor)
          # Copy the Ruby object graph; no serialization, parser or temp files.
          root = Marshal.load(Marshal.dump(semantic_root))
          root.type = "presentation"
          tree = Metanorma::Iso::Presentation::ModelTree.new(root)
          check_supported!(tree)
          tree.assign_ids!
          label(root, flavor, options)
          Metanorma::Iso::Presentation::Display.new(tree).apply
          root
        end

        private

        def check_input!(semantic_root, flavor)
          iec_root = Metanorma::Iec::Document::Root
          return if semantic_root.instance_of?(iec_root) && flavor.to_s == "iec"

          raise ArgumentError,
                "Native IEC presentation requires an IEC Root and flavor :iec"
        end

        def label(root, flavor, options)
          labeler = options[:document_labeler] || default_labeler
          return if labeler.call(root, flavor: flavor, options: options)
            .equal?(root)

          raise ArgumentError,
                "document_labeler must return its supplied IEC Root"
        end

        def default_labeler
          engine = Metanorma::Ladl::Engine.new(
            profile: Metanorma::Ladl::Profile.iso_iec,
          )
          lambda do |model, **_context|
            engine.call(model, adapter: Adapter.new(mode: :presentation))
          end
        end

        # LADL's adapter recognises only the generic and ISO roots; IEC's root
        # is a sibling class, so accept it here until LADL does.
        class Adapter < Metanorma::Ladl::DocumentAdapter
          private

          def root?(node)
            super || node.is_a?(Metanorma::Iec::Document::Root)
          end
        end
      end
    end
  end
end
