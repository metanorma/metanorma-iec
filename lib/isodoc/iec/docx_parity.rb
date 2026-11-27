# Token-level parity for IEC DOCX round-trip checks. Ported from the pure
# alignment core of metanorma-iso lib/isodoc/iso/docx/mhtml_parity.rb.
# The MHTML and DOCX readers are NOT ported yet: they need a submitted IEC
# artifact to test against (none found in the org as of 2026-11-27).
module IsoDoc
  module Iec
    module DocxParity
      module_function

      # Returns report lines for two token arrays (one token per structure or
      # style element). ["MATCH"] when they are equal.
      def report_lines(expected, actual)
        return ["MATCH"] if expected == actual

        matches = Alignment.new(expected, actual).matches
        if matches.compact.each_cons(2).all? { |a, b| a < b }
          ordered_lines(expected, actual, matches)
        else
          delta_lines(expected, actual, matches)
        end
      end

      def ordered_lines(expected, actual, matches)
        lines = []
        old_position = new_position = 0
        matches = matches.dup
        matches[expected.length] = actual.length
        matches.each_with_index do |new_match, old_match|
          next if new_match.nil?

          while old_position < old_match || new_position < new_match
            if old_position < old_match
              lines << "- #{old_position + 1}: #{expected[old_position]}"
              old_position += 1
            end
            if new_position < new_match
              lines << "+ #{new_position + 1}: #{actual[new_position]}"
              new_position += 1
            end
          end
          old_position = old_match + 1
          new_position = new_match + 1
        end
        lines
      end

      # Multiset matches need not be ordered: report unmatched occurrences
      # only, keeping their original one-based positions.
      def delta_lines(expected, actual, matches)
        matched_actual = matches.compact.to_h { |position| [position, true] }
        removed = expected.each_index.filter_map do |position|
          "- #{position + 1}: #{expected[position]}" if matches[position].nil?
        end
        added = actual.each_index.filter_map do |position|
          unless matched_actual[position]
            "+ #{position + 1}: #{actual[position]}"
          end
        end
        Array.new([removed.size, added.size].max) do |index|
          [removed[index], added[index]]
        end.flatten.compact
      end

      class Alignment
        # Keep ordinary artifacts' exact alignment and tie-breaking. Large
        # artifacts align a bounded leading window after prefix/suffix trim;
        # the rest is a multiset delta (ordering there is not compared).
        MAX_EXACT_TOKENS = 100_000
        WINDOW_TOKENS = 2_048

        def initialize(expected, actual)
          @expected = expected
          @actual = actual
          @matches = []
          @links = {}
        end

        def matches
          first, last_expected, last_actual = trim
          if [last_expected, last_actual].max - first + 1 > MAX_EXACT_TOKENS
            return bounded_matches(first, last_expected, last_actual)
          end

          masks = Hash.new(0)
          (first..last_actual).each do |position|
            masks[@actual[position]] |= 1 << (position - first)
          end
          row = 0
          (first..last_expected).each do |position|
            # Set bits mark the smallest actual endpoint for each LCS length.
            # Subtraction propagates each threshold to its next matching bit;
            # unchanged thresholds retain their original predecessor links.
            union = row | masks[@expected[position]]
            next_row = union & ~(union - ((row << 1) | 1))
            update_links(row, next_row, position, first)
            row = next_row
          end
          link = @links[row.bit_length - 1]
          while link
            @matches[link[1]] = link[2]
            link = link[0]
          end
          @matches
        end

        private

        def bounded_matches(first, last_expected, last_actual)
          expected_end = [first + WINDOW_TOKENS, last_expected + 1].min
          actual_end = [first + WINDOW_TOKENS, last_actual + 1].min
          window = self.class.new(@expected[first...expected_end],
                                  @actual[first...actual_end]).matches
          # An indel can move matching tokens across the fixed window edge.
          # Resume both tails immediately after the last aligned pair.
          expected_end = actual_end = first
          window.each_with_index do |match, position|
            next unless match

            @matches[first + position] = first + match
            expected_end = first + position + 1
            actual_end = first + match + 1
          end
          multiset_matches(expected_end, actual_end, last_expected, last_actual)
          @matches
        end

        def multiset_matches(first_expected, first_actual,
                           last_expected, last_actual)
          positions = Hash.new { |hash, token| hash[token] = [] }
          last_actual.downto(first_actual) do |position|
            positions[@actual[position]] << position
          end
          (first_expected..last_expected).each do |position|
            @matches[position] = positions[@expected[position]].pop
          end
        end

        def trim
          first = 0
          last_expected = @expected.length - 1
          last_actual = @actual.length - 1
          while first <= last_expected && first <= last_actual &&
              @expected[first] == @actual[first]
            @matches[first] = first
            first += 1
          end
          while first <= last_expected && first <= last_actual &&
              @expected[last_expected] == @actual[last_actual]
            @matches[last_expected] = last_actual
            last_expected -= 1
            last_actual -= 1
          end
          [first, last_expected, last_actual]
        end

        def update_links(row, next_row, position, offset)
          # Descending order leaves each predecessor on the previous row.
          each_bit(next_row & ~row) do |index, bit|
            previous = (row & (bit - 1)).bit_length - 1
            @links[index] = [@links[previous], position, index + offset]
          end
          each_bit(row & ~next_row) { |index, _bit| @links.delete(index) }
        end

        def each_bit(bits)
          until bits.zero?
            index = bits.bit_length - 1
            bit = 1 << index
            yield index, bit
            bits ^= bit
          end
        end
      end
    end
  end
end
