#!/bin/bash
tree -ifc $1 | grep fastp.log | xargs -I foo sh -c "echo '#####' foo; cat foo" | perl -a -F"\s+" -ne 'chomp; if($_=~/^#.*\/(.*)\.fastp.log$/){print "$1\t"}elsif($_=~/^total reads:|total bases/){print "@F[2]\t"}elsif($_=~/reads passed/){print "@F[3]\n"}'
