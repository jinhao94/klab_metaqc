#!/bin/bash
less $1 | perl -lane 'if($_=~/Raw_r1_reads/){print "$_\tFinal_total_reads\tFinal_total_bases"; next}; $read_sum=@F[-10]+@F[-5]; $base_sum=@F[-9]+@F[-4]; print "$_\t$read_sum\t$base_sum"' 
