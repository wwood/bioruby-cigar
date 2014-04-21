require 'bio-samtools'

class Bio::DB::Alignment
  # Work out the percent identity given of the query sequence
  # against the reference sequence, using the CIGAR string as
  # the alignment
  #
  # Options:
  # :reference_starting_position: only consider the from this position in the reference sequence
  # :alignment_length: only consider this much of the reference sequence
  def percent_identity(reference_sequence, options={})
    return Bio::Cigar.new(self.cigar).percent_identity(
      reference_sequence[self.pos-1...reference_sequence.length],
      self.seq
    )
  end
end
