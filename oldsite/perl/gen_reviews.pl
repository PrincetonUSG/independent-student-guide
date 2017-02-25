#!/usr/psr/bin/perl
use strict;
use warnings;
use lib '/u/isg/perllib';
use YAML qw/LoadFile/;
use CGI qw/:html *table *Tr/;

{
    my $even;
    sub theo { print th(@_); }
    sub tdeo { print td({class=>($even^=1)?'even':'odd'}, @_); }
    sub srow { $even = 0; print start_Tr(); }
    sub erow { print end_Tr(); }
}
my $info = LoadFile 'lists/restaurant.yaml';
print start_table({class=>'chart'});
my @headers = qw/Name Address Phone Order/;
srow(); theo($_) for @headers; erow();
for my $r (@{$info->{restaurants}}) {
    srow();
    my %a = map { $_=>'' } qw/city state street zip/;
    %a = (%a, map { $_=>$r->{address}{$_} } keys %{$r->{address}});
    for my $k (keys %a) {
        $a{$k} =~ tr/ /+/;
        $a{$k} =~ s/[^A-Za-z0-9+]/sprintf "%%%02X", ord $&/ge;
    }
    my @map;
    for my $m (@{$info->{maps}}) {
        my $url = $m->{url};
        $url =~ s/\$([a-z]+)/sprintf "%s", ($a{$1}||"NO:$1")/ge;
        push @map, $a{street} ? a({class=>"maplink",href=>$url}, $m->{text}) : '';
    }
    my @fields = qw/name href menu phone/;
    my %o = map { $_=>'' } @fields;
    %o = (%o, map { $_=>$r->{order}{$_} } @fields);
    $o{menu} = $r->{menu} || $o{menu};
    $o{href} &&= a({href=>$o{href}},$o{name}).br.$o{phone};
    $o{menu} &&= a({href=>$o{menu}},'[Menu]');
    my $name = $r->{href} ? a({href=>$r->{href}}, $r->{name}) : $r->{name};
    my $type = $r->{type} ? '('.join(', ',@{$r->{type}}).')' : '';
    $type &&= span({class=>'note'}, $type);
    my $address = $r->{address}{street} || '';
    my $maps = join '&nbsp;', @map;
    my $phone = $r->{phone} || '';
    my $menu = $o{menu} || '';
    my $link = $o{href} || '';
    my @row = ( join(br, $name, $type),
                join(br, $address, $maps),
                $phone,
                join(br, $menu, $link) );
    tdeo($_) for @row;
    erow();
}
print end_table;
