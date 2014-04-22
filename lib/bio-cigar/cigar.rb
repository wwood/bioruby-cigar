module Bio
  class Cigar
    attr_accessor :cigar_string

    def initialize(cigar_string)
      @cigar_string = cigar_string
    end

    # Given a reference sequence and a query sequence, return an Array of 3 values:
    # [% identity, num_match, num_mismatch].
    #
    # Options:
    # :reference_starting_position: only consider the from this position in the reference sequence. Note this is 1-based indices, not 0-based
    # :alignment_length: only consider this much of the reference sequence (requires :reference_starting_position to be specified also.)
    def percent_identity(reference_sequence_string, query_sequence_string, options={})
      num_match = 0
      num_mismatch = 0

      ref_index = 0
      query_index = 0
      each_alignment_chunk do |type, count|
        puts "ref_i=#{ref_index}, query_index=#{query_index}, num_match=#{num_match}, num_mismatch=#{num_mismatch}"
        puts "#{type} #{count}"
        puts "ref=#{reference_sequence_string[ref_index...(reference_sequence_string.length)] }"
        puts "query=#{query_sequence_string[query_index...(query_sequence_string.length)] }"
        if options[:alignment_length] and ref_index >= options[:reference_starting_position]+options[:alignment_length]
          puts 'breaking'
          break
        end

        case type
        when 'I'
          # Extra characters in the query sequence
          num_mismatch += count if options[:reference_starting_position].nil? or ref_index+1 < options[:reference_starting_position]
          query_index += count
        when 'D'
          (0...count).each do |i|
            puts "Deleting at i #{i}"
            if options[:reference_starting_position].nil? or ref_index+1 >= options[:reference_starting_position]
              if options[:alignment_length] and ref_index+1 >= options[:reference_starting_position]+options[:alignment_length]
                puts 'breaking2'
                break #alignment region ends in the middle of a deletion
              end
              num_mismatch += 1
            end
            ref_index += 1
          end
        when 'S'
          #ref_index += count
          query_index += count
        when 'H'
          query_index += count
        when 'P'
          # Do nothing
        when 'N'
          # long skip on the reference sequence
          ref_index += count
        else
          if %w(M = X).include?(type)
            # For = and X, treat as if they were an M for ease of programming this method.
            (0...count).each do |i|
              if options[:alignment_length] and ref_index+1 >= options[:reference_starting_position]+options[:alignment_length]
                # alignment region ends
                puts 'breaking3'
                break
              end

              if options[:reference_starting_position].nil? or ref_index+i+1 >= options[:reference_starting_position]
                puts "comparing at #{i}"
                if reference_sequence_string[ref_index+i] == query_sequence_string[query_index+i]
                  num_match += 1
                else
                  num_mismatch += 1
                end
              end
            end
            ref_index += count
            query_index += count
          else
            raise "Cigar string not parsed correctly. Unrecognised alignment type #{type}"
          end
        end

        #puts "after, ref_i=#{ref_index}, query_index=#{query_index}, num_match=#{num_match}, num_mismatch=#{num_mismatch}"
      end

      percent = num_match.to_f / (num_match+num_mismatch)*100
      return percent, num_match, num_mismatch
    end

    # Yield the type and count for each different part of the
    # cigar string e.g.
    #
    #    cigar = Bio::Cigar.new('1S3M')
    #    cigar.each_alignment_chunk do |type, count|
    #        type #=> first 'S', second 'M' (as strings)
    #        type #=> first 1, second 3 (as integers)
    #    end
    def each_alignment_chunk
      leftover = @cigar_string
      while matches = leftover.match(/^(\d+)([MSIHNDP\=X])(.*)/)
        yield matches[2], matches[1].to_i
        leftover = matches[3]
      end
      unless leftover.length == 0
        raise "Incorrect parsing of cigar string #{@cigar_string}, at the end left with #{leftover}"
      end
    end
  end
end
