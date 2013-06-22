# bio-cigar

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-cigar.png)](http://travis-ci.org/wwood/bioruby-cigar)

Parser for the cigar sequence alignment format.

Note: this software is under active development!

## Installation

```sh
gem install bio-cigar
```

## Usage

```ruby
require 'bio-cigar'

# An example from http://davetang.org/wiki/tiki-index.php?page=SAM
# CIGAR: 3S8M1D6M4S
cigar_string = '3S8M1D6M4S'
cigar = Bio::Cigar.new(cigar_string) #=> Bio::Cigar object

# REF:  GTGTCGCCCGTCTAGCATACGC
# READ: gggGTGTAACC-GACTAGgggg
# MATCH:---001000000010010----
ref =   'GTGTCGCCCGTCTAGCATACGCCCGTCTAGCATACGC'
query = 'gggGTGTAACCGACTAGgggg'
answer = cigar.percent_identity(ref, query)
answer.should == [
  20.0, #20% Identity
  3, #3 matches
  12 #12 mismatches
]
```
It can also be used directly on SAM format alignments (```Bio::DB::Alignment``` objects),
which are produced by ```bio-samtools```:
```ruby
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
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-cigar

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

This software is currently unpublished.

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-cigar)

## Copyright

Copyright (c) 2013 Ben J Woodcroft. See LICENSE.txt for further details.

