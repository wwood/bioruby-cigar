require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BioCigar" do
  it "should do as in the README" do
    cigar_string = '3S8M1D6M4S'
    cigar = Bio::Cigar.new(cigar_string) #=> Bio::Cigar object
    cigar.should be_kind_of(Bio::Cigar)

    # REF:  GTGTCGCCCGTCTAGCATACGC
    # READ: gggGTGTAACC-GACTAGgggg
    # MATCH:---001000000010010----
    ref =     'TCGCCCGTCTAGCATACGC'
    query = 'gggGTGTAACCGACTAGgggg'
    cigar.percent_identity(ref, query).should == [20.0, 3, 12] #=> 20.0 (3/15 is 20% identity)
  end

  it 'should alignment chunk right' do
    cigar_string = '3S8M1D6M4S'
    types = []
    counts = []
    cigar = Bio::Cigar.new(cigar_string)
    cigar.each_alignment_chunk do |type, count|
      types.push type
      counts.push count
    end
    types.should == %w(S M D M S)
    counts.should == [3,8,1,6,4]
    cigar_string.should == '3S8M1D6M4S' #shouldn't modify the passed string
  end

  it 'should work on real data' do
    # SAM:
    # 790     16      2303416 1150    1       196M54S *       0       0       ACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGCCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCCAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCCCTAGTAATCGCGTGTCATTAGCGCGCGGTGAATACGTCCCTGCTCCTTGCACTCACCGCCCGT      *       AS:i:184
    ref = 'GAGCGAACGTTAGCGGCGGGCTTAACACATGCAAGTCGAACGAGAATGAAGGAGCAATCCTTCTAGTAAAGTGGCGGACGGGTGCGTAACACGTGGATAATCTACCTTCCGGCGGGGGACAACAGTTCGAAAGGACTGCTAATACCGCGTACGTCGGCGAGAGCTCAGGCTCTTGTCGGGAAAGATGGCCAATCCTTGGAAGCTGTCACCGGAAGATGAATCCGCGGCCCATCAGGTAGTTGGTGAGGTAATGGCTCACCAAGCCTAAGACGGGTAGCTGGTCTGAGAGGATGATCAGCCACACTGGGACTGCGACACGGCCCAGACTCCTACGGGAGGCAGCAGTGGGGAATATTGGGCAATGGGCGAAAGCCTGACCCAGCCACGCCGCGTGAGTGATGAAGGCCTTCGGGTCGTAAAGCTCTGTGGGGAGGGACGAACAAGTGCGTATCGAATAAATACGTGCCCTGACGGTACCTCCTTAGCAAGCACCGGCTAACCATGTGCCAGCAGCCGCGGTAATACATGGGGTGCAAACGTTGCTCGGAATTATTGGGCGTAAAGCGCGCGTAGGCGGTCGCTTAAGTCGGATGTGAAATCCCTCGGCTTAACTGAGGAAGTGCATCCGAGACTGAATGGCTAGAGTACGAAAGAGGGTCGNNNNNTTCCCGGTGTAGAGGTGAAATTCGTAGATATCGGGAGGAACACCGGCGGCGAAGGCGGCGACCTGGTTCGAGACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACAGGATTAGATACCCTGGTAGTCCACGCCGTAAACGATGGATGCTAGATGTTTCTGGTATTGACCCCGGAGGCGTCGTAGCTAACGCGATAAGCATCCCGCCTGGGGAGTACGGCCGCAAGGCTAAAACTCAAAGGAATTGACGGGGGCCCGCACAAGCGGTGGAGCATGTGGTTCAATTTGACGCAACGCGAAGAACCTTACCTGGGTTGGAACCCTCCAGAAGTCCGCAGAGATGTGGATGTGCTCGCAAGAGAACTGGATGTCCAGGTGCTGCATGGCTGTCGTCAGCTCGTGTCGTGAGATGTTGGGTTAAGTCCCGCAACGAGCGCAACCCTTGTCGTTAGTTGCTAACAGTTCGGCTGAGCACTCTAACGAGACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGTCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCTAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCGCTAGTAATCCCTGATCAGCAGGCAGGGGTGAATACGTTCCCGGGCC'
    query = 'ACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGCCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCCAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCCCTAGTAATCGCGTGTCATTAGCGCGCGGTGAATACGTCCCTGCTCCTTGCACTCACCGCCCGT'
    pos = 1150

    ref_seq = ref[pos-1...ref.length]
    Bio::Cigar.new('196M54S').percent_identity(ref_seq, query).should == [
      98.46938775510205,
      193,
      3
    ]
  end

  it 'should monkey patch SAM alignments' do
    sam = Bio::DB::Alignment.new
    sam.cigar = '196M54S'
    sam.pos = 1150
    sam.seq = 'ACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGCCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCCAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCCCTAGTAATCGCGTGTCATTAGCGCGCGGTGAATACGTCCCTGCTCCTTGCACTCACCGCCCGT'
    ref = 'GAGCGAACGTTAGCGGCGGGCTTAACACATGCAAGTCGAACGAGAATGAAGGAGCAATCCTTCTAGTAAAGTGGCGGACGGGTGCGTAACACGTGGATAATCTACCTTCCGGCGGGGGACAACAGTTCGAAAGGACTGCTAATACCGCGTACGTCGGCGAGAGCTCAGGCTCTTGTCGGGAAAGATGGCCAATCCTTGGAAGCTGTCACCGGAAGATGAATCCGCGGCCCATCAGGTAGTTGGTGAGGTAATGGCTCACCAAGCCTAAGACGGGTAGCTGGTCTGAGAGGATGATCAGCCACACTGGGACTGCGACACGGCCCAGACTCCTACGGGAGGCAGCAGTGGGGAATATTGGGCAATGGGCGAAAGCCTGACCCAGCCACGCCGCGTGAGTGATGAAGGCCTTCGGGTCGTAAAGCTCTGTGGGGAGGGACGAACAAGTGCGTATCGAATAAATACGTGCCCTGACGGTACCTCCTTAGCAAGCACCGGCTAACCATGTGCCAGCAGCCGCGGTAATACATGGGGTGCAAACGTTGCTCGGAATTATTGGGCGTAAAGCGCGCGTAGGCGGTCGCTTAAGTCGGATGTGAAATCCCTCGGCTTAACTGAGGAAGTGCATCCGAGACTGAATGGCTAGAGTACGAAAGAGGGTCGNNNNNTTCCCGGTGTAGAGGTGAAATTCGTAGATATCGGGAGGAACACCGGCGGCGAAGGCGGCGACCTGGTTCGAGACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACAGGATTAGATACCCTGGTAGTCCACGCCGTAAACGATGGATGCTAGATGTTTCTGGTATTGACCCCGGAGGCGTCGTAGCTAACGCGATAAGCATCCCGCCTGGGGAGTACGGCCGCAAGGCTAAAACTCAAAGGAATTGACGGGGGCCCGCACAAGCGGTGGAGCATGTGGTTCAATTTGACGCAACGCGAAGAACCTTACCTGGGTTGGAACCCTCCAGAAGTCCGCAGAGATGTGGATGTGCTCGCAAGAGAACTGGATGTCCAGGTGCTGCATGGCTGTCGTCAGCTCGTGTCGTGAGATGTTGGGTTAAGTCCCGCAACGAGCGCAACCCTTGTCGTTAGTTGCTAACAGTTCGGCTGAGCACTCTAACGAGACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGTCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCTAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCGCTAGTAATCCCTGATCAGCAGGCAGGGGTGAATACGTTCCCGGGCC'
    sam.percent_identity(ref).should == [
      98.46938775510205,
      193,
      3
    ]
  end

  it 'should work on real data 2' do
    #SRR400867.981	0	3225199 9	4	10S240M *	0	0	TCAGAGCTACAAGAGTTTGATCGTGGCTCAGAAGGAACGCTAGCTATATGCTTAACACATGCAAGTCGAACGTTGTTTTCGGGGAGCTGGGCAGAAGGAAAAGAGGCTCCTAGCGTGAAGGTAGCTTGTCTCGCCCAGGAGGTGGGAACAGTTGAAAACAAAGTGGCGAACGGGTGCGTAATGCGTGGGAATCTGCCGAACAGTTCGGGCCAAATCCTGAAGAAAGCTAAAAAGCGCTGTTTGATGAGCC	*	AS:i:236	XS:i:232	XF:i:3	XE:i:2	NM:i:1
    ref = 'CTCAAAAGAAGAGTTTGATCCTGGCTCAGAAGGAACGCTAGCTATATGCTTAACACATGCAAGTCGAACGTTGTTTTCGGGGAGCTGGGCAGAAGGAAAAGAGGCTCCTAGCGTGAAGGTAGCTTGTCTCGCCCAGGAGGTGGGAACAGTTGAAAACAAAGTGGCGAACGGGTGCGTAATGCGTGGGAATCTGCCGAACAGTTCGGGCCAAATCCTGAAGAAAGCTAAAAAGCGCTGTTTGATGAGCCTGCGTAGTATTAGGTAGTTGGTCAGGTAAAGGCTGACCAAGCCAATGATGCTTAGCTGGTCTTTTCGGATGATCAGCCACACTGGGACTGAGACACGGCCCGGACTCCCACGGGGGGCAGCAGTGGGGAATCTTGGACAATGGGCGAAAGCCCGATCCAGCAATATCGCGTGAGTGAAGAAGGGCAATGCCGCTTGTAAAGCTCTTTCGTCGAGTGCGCGATCACGACAGGACTCGAGGAAGAAGCCCCGGCTAACTCCGTGCCAGCAGCCGCGGTAAGACGGGGGGGGCAAGTGTTCTTCGGAATGACTGGGCGTAAAGGGCACGTAGGCGGTGAATCGGGTTGAAAGTGAAAGTCGCCAAAAACTGGTGGAATGCTCTCGAAACCAATTCACTTGAGTGAGACAGAGGAGAGTGGAATTTCGTGTGTAGGGGTGAAATCCGCAGATCTACGAAGGAAGGCCAAAAGCGAAGGCAGCTCTCTGGGTCCCTACCGACGCTGGAGTGCGAAAGCATGGGGAGCGAACGGGATTAGATACCCTGGTAGTCCATGCCGTAAACGATGAGTGTTCGCCCTTGGTCTACGTGGATCAGGGGCCCAGCTAACGCGTGAAACACTCCGCCTGGGGAGTACGGTCGCAAGACCGAAACTCAAAGGAATTGACGGGGGCCTGCACAAGCGGTGGAGCATGTGGTTTAATTCGATACAACGCGCAAAACCTTACCAGCCCTTGAAATATGAAAAAGAAAACCAGTCCTTAACGGGATGGTACTTACTTTCATACAGGTGCTGCATGGCTGTCGTCAGCTCGTGTCGTGAGATGTTTGGTCAAGTCCTATAACGAGCGAAACCCTCGTTTTGTGTTGCTGAGACATGCGCCTAAGGATAAAGTCTTTGCAACCGAAGTGAGCCGAGGAGCCGAGTGACGCGCCAGCGCTACTAATTTATTTAGTGCCAGCACGTAGCTGTGCTGTCAGTAAGAAGGGAGCCGGCGCCTTTCGAATTCGAAGCACTTTCTAGTGTGCGCTCTTTTTTGATTGCAGCTAGCGAGCAAGAAAACGGATGCGCGTTAGCCTTTATTAGTAATAGTAATGGAGGCTTTCTTTTTTTCAGCTCAATCCCTTGCTTCTTGCTTTACTAAATAGAAAGGGCTTTTCTCGCTTTTTTAGTAAAGTCCAGTTTTTGGCCTTATCTTGCAGGTGACGACGACGTCGAGTTGGCGGCGGAGAAAGACTCGGCATTCAGGCGAGCCGCCCGGTGGTGTGGTACGTAGTGGGTTTAGTACGCCCCGCCAAAACGGCTCCGAAAGAAACTAAAAGGTGCATGCCGCACTCACGAGGGACTGCCAGTGATATACTGGAGGAAGGTGGGGATGACGTCAAGTCCGCATGCCCTTATGGGCTGGGCCACACACGTGCTACAATGGCAATTACAATGGGAAGCAAGGCTGTAAGGCGGAGCGAATCCGGAAAGATTGCCTCAGTTCGGATTGTTCTCTGCAACTCGGGAACATGAAGTTGGAATCGCTAGTAATCGCGGATCAGCATGCCGCGGTGAATATGTACCCGGGCCCTGTACACACCGCCCGTCACACCCTGGGAATTGGTTTCGCCCGAAGCATCGGACCAATGATCACCCATGACTTCTGTGTACCACTAGTGCCACAAAGGCTTTTGGTGGTCTTCTTGGCGCATACCACGGTGGGGTCTTCGACTGGGGTGAAGTCGTAACAAGGTAGCCGTAGGGGAACCTGTGGCTGGAT'
    sam = Bio::DB::Alignment.new
    sam.cigar = '10S240M'
    sam.pos = 9
    sam.seq = 'TCAGAGCTACAAGAGTTTGATCGTGGCTCAGAAGGAACGCTAGCTATATGCTTAACACATGCAAGTCGAACGTTGTTTTCGGGGAGCTGGGCAGAAGGAAAAGAGGCTCCTAGCGTGAAGGTAGCTTGTCTCGCCCAGGAGGTGGGAACAGTTGAAAACAAAGTGGCGAACGGGTGCGTAATGCGTGGGAATCTGCCGAACAGTTCGGGCCAAATCCTGAAGAAAGCTAAAAAGCGCTGTTTGATGAGCC'
    sam.percent_identity(ref)[0].should == 99.58333333333333
  end

  it 'should work with padded reference seqs' do
    ref = 'CCGG'
    sam = Bio::DB::Alignment.new
    sam.cigar = '2M1P1I1P3I2M'
    sam.pos = 1
    sam.seq = 'CCAGGTGG'
    sam.percent_identity(ref).should == [
      50.0,
      4,
      4,
      ]
  end

  it 'should work with X and =' do
    # SAM:
    # 790     16      2303416 1150    1       196M54S *       0       0       ACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGCCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCCAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCCCTAGTAATCGCGTGTCATTAGCGCGCGGTGAATACGTCCCTGCTCCTTGCACTCACCGCCCGT      *       AS:i:184
    ref = 'GAGCGAACGTTAGCGGCGGGCTTAACACATGCAAGTCGAACGAGAATGAAGGAGCAATCCTTCTAGTAAAGTGGCGGACGGGTGCGTAACACGTGGATAATCTACCTTCCGGCGGGGGACAACAGTTCGAAAGGACTGCTAATACCGCGTACGTCGGCGAGAGCTCAGGCTCTTGTCGGGAAAGATGGCCAATCCTTGGAAGCTGTCACCGGAAGATGAATCCGCGGCCCATCAGGTAGTTGGTGAGGTAATGGCTCACCAAGCCTAAGACGGGTAGCTGGTCTGAGAGGATGATCAGCCACACTGGGACTGCGACACGGCCCAGACTCCTACGGGAGGCAGCAGTGGGGAATATTGGGCAATGGGCGAAAGCCTGACCCAGCCACGCCGCGTGAGTGATGAAGGCCTTCGGGTCGTAAAGCTCTGTGGGGAGGGACGAACAAGTGCGTATCGAATAAATACGTGCCCTGACGGTACCTCCTTAGCAAGCACCGGCTAACCATGTGCCAGCAGCCGCGGTAATACATGGGGTGCAAACGTTGCTCGGAATTATTGGGCGTAAAGCGCGCGTAGGCGGTCGCTTAAGTCGGATGTGAAATCCCTCGGCTTAACTGAGGAAGTGCATCCGAGACTGAATGGCTAGAGTACGAAAGAGGGTCGNNNNNTTCCCGGTGTAGAGGTGAAATTCGTAGATATCGGGAGGAACACCGGCGGCGAAGGCGGCGACCTGGTTCGAGACTGACGCTGAGGCGCGAAAGCGTGGGGAGCAAACAGGATTAGATACCCTGGTAGTCCACGCCGTAAACGATGGATGCTAGATGTTTCTGGTATTGACCCCGGAGGCGTCGTAGCTAACGCGATAAGCATCCCGCCTGGGGAGTACGGCCGCAAGGCTAAAACTCAAAGGAATTGACGGGGGCCCGCACAAGCGGTGGAGCATGTGGTTCAATTTGACGCAACGCGAAGAACCTTACCTGGGTTGGAACCCTCCAGAAGTCCGCAGAGATGTGGATGTGCTCGCAAGAGAACTGGATGTCCAGGTGCTGCATGGCTGTCGTCAGCTCGTGTCGTGAGATGTTGGGTTAAGTCCCGCAACGAGCGCAACCCTTGTCGTTAGTTGCTAACAGTTCGGCTGAGCACTCTAACGAGACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGTCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCTAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCGCTAGTAATCCCTGATCAGCAGGCAGGGGTGAATACGTTCCCGGGCC'
    query = 'ACTGCCGGTGTTAAACCGGAGGAAGGTGGGGATGACGTCAAGTCCTCATGGCCCTTATGCCCAGGGCTACACACGTGCTACAATGGCCGTTACAAAGCGTCGCTAACCCGCGAGGGGGAGCCAATCGCAAAAAAGCGGCCTCAGTTCAGATTGCAGTCTGCAACTCGACTGCATGAAGTTGGAATCCCTAGTAATCGCGTGTCATTAGCGCGCGGTGAATACGTCCCTGCTCCTTGCACTCACCGCCCGT'
    pos = 1150

    ref_seq = ref[pos-1...ref.length]
    Bio::Cigar.new('100X96=54S').percent_identity(ref_seq, query).should == [ #This example is a little fake because X and = are not true, but it is re-calculated in the code so should not matter
      98.46938775510205,
      193,
      3
    ]
  end

  it 'should work with N' do
    ref =   'GTGTCGCCCGTCTAGCATACGCATGATCGACTGTCAGCTAGTCAGACTA'
    query = 'GTGTAACCC'+                             'TCAGAATA'
    sam = Bio::DB::Alignment.new
    sam.cigar = '9M32N8M'
    sam.pos = 1
    sam.seq = query
    expected_matches = 4+3+4+3
    expected_mismatches = 2+1
    sam.percent_identity(ref).should == [
      expected_matches.to_f/ (expected_matches+expected_mismatches)*100,
      expected_matches,
      expected_mismatches,
      ]
  end

  it 'should work with an alignment length for easy case' do
    cigar_string = '3S8M1D6M4S'
    cigar = Bio::Cigar.new(cigar_string) #=> Bio::Cigar object
    cigar.should be_kind_of(Bio::Cigar)

    # REF:  GTGTCGCCCGTCTAGCATACGC
    # READ: gggGTGTAACC-GACTAGgggg
    # MATCH:---001000000010010----
    ref =     'TCGCCCGTCTAGCATACGC'
    query = 'gggGTGTAACCGACTAGgggg'
    cigar.percent_identity(ref, query, :reference_starting_position => 1).should == [20.0, 3, 12] #=> 20.0 (3/15 is 20% identity)

    cigar.percent_identity(ref, query, :reference_starting_position => 3)[1..2].should == [3, 10]
    cigar.percent_identity(ref, query, :reference_starting_position => 4)[1..2].should == [2, 10]
    cigar.percent_identity(ref, query, :reference_starting_position => 10)[1..2].should == [2, 4]
  end

  it 'should work with contrained alignment length' do
    cigar_string = '3S8M1D6M4S'
    cigar = Bio::Cigar.new(cigar_string) #=> Bio::Cigar object
    cigar.should be_kind_of(Bio::Cigar)

    # REF:  GTGTCGCCCGTCTAGCATACGC
    # READ: gggGTGTAACC-GACTAGgggg
    # MATCH:---001000000010010----
    ref =     'TCGCCCGTCTAGCATACGC'
    query = 'gggGTGTAACCGACTAGgggg'
    cigar.percent_identity(ref, query,
      {
        :reference_starting_position => 1,
        :alignment_length => 15
        }).should == [20.0, 3, 12] #=> 20.0 (3/15 is 20% identity)

    cigar.percent_identity(ref, query,
      {
        :reference_starting_position => 1,
        :alignment_length => 14
        })[1..2].should == [3, 11]

    #TODO: more testing e.g. breaking within a deletion, on a boundary, different starting positions.
  end
end
