#!/bin/bash
cut -f1,4-8 - | perl -lane 'if($_=~/^file/){next}; @F[0]=~/.*\/(.*).clean/; $o=(join "\t", @F[1..$#F]); print "$1\t$o"' | perl -e 'while(<>){chomp; @s=split /\t/; if(@s[0] ne $n){print "$_\t"; $n=@s[0]}else{$o=(join "\t", @s[1..$#s]); print "$o\n"} }'
