#!/usr/psr/bin/perl
use strict;
use warnings;
use lib '/u/isg/perllib';
use YAML qw/LoadFile/;
my $y = LoadFile qw|lists/Discounts.yaml|;
use CGI qw/:html *table *Tr/;

print <DATA>;

do {
    my $e=0;
    sub tdeo { $e^=1; print td({class=>$e?'even':'odd'}, @_) }
    sub theo { print th(@_) }
    sub srow { $e=0; print start_Tr() }
    sub erow { print end_Tr() }
};

print start_table({class=>'chart'});
srow(); theo($_) for @{$y->{headers}}; erow();
for my $r (@{$y->{discounts}}) {
    srow(); tdeo($_) for @{$r->{discount}}; erow();
}
print end_table();

__DATA__
<h2>The USG has negotiated student discounts at local merchants</h2>
<h3>All discounts are available to students with valid PUID.</h3>
