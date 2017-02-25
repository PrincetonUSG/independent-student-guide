#!/usr/psr/bin/perl
use strict;
use warnings;
use lib '/u/isg/perllib';
use YAML qw/LoadFile/;
use Getopt::Long;
Getopt::Long::Configure(qw/bundling/);
my @options = ( 'config=s' => \ (my $config = 'config.yaml'),
                'debug|d'  => \ (my $debug  = 0),
                'help|usage|h|?' => \ (my $usage = 0),
                );
GetOptions(@options) or $usage = 1;
die join("\n", keys %{{(@options)}}) if $usage;

my $conf  = LoadFile($config) or die 'config';

chdir $conf->{basedir} or die 'basedir';
my $menu = $conf->{menu} or die 'menu';
my @pages = @{LoadFile($conf->{pages})} or die 'pages';

my $maximg = 1 + scalar @pages;

my $menutext;
# $menutext = '<table class="menu">';
$menutext = "<div id=\"menu\">\n";
my $javascript = '<script type="text/javascript"><!--'."\n";
$javascript .= "hover = new Array($maximg);\nfor(var i = 0; i < $maximg; i++) { hover[i] = new Image(); }\n";
my $jc = 1;
open MENU, '>', $menu or die 'opening menu: ', $menu, $!;
$conf->{$_} =~ s/(?<!\\)\$([a-z]+)/\$h->{$1}/g for keys %$conf;
foreach my $h (@pages) {
    my %h = ( ( map { $_ => eval "qq{$conf->{$_}}" } keys %$conf ),
              ( map { $_ => eval "qq{$h->{$_}}"    } keys %$h    ) );
    warn "Skipping $h{name}\n" and next if $h{skip};
    if ($h{gen}) {
        my ($text, $tosub);
        if ($h{gen} eq 'special') {
            print STDERR "Special: $h{gen} $h{name}\n";
            system 'bash', '-c', "$^X $h{special} > $h{html}" and
                do { warn "special failed: $^X $h{special} > $h{html}\n"; next; };
        }
        if ($debug) { $h{html} = $h{debughtml} unless -f $h{html} and -r _; }
        warn "file: $h{html}\n" and next unless -f $h{html} and -r _;
        $text = '<!--#include virtual="$htmlurl" -->';
        open STDOUT, '>', $h{shtml};
        open STDIN, '<', $h{base} or do { warn "base: $h{base} $!\n"; next; };
        $tosub = do { undef $/; <STDIN> };
        $tosub =~ s/SUB_TEXT_SUB/$h{header}$text/;
        $tosub =~ s/\$([a-z]+)/$h{$1} || ""/ge;
        print $tosub;
        close STDOUT;
    }
    # $menutext .= "<tr><td><a href=\"$h{href}\" onmouseover=\"onImg($jc)\" onmouseout=\"offImg($jc)\">$h{desc}</a></td></tr>\n";
    $menutext .= "<div><a class=\"menuitem\" href=\"$h{href}\" onmouseover=\"onImg($jc)\" onmouseout=\"offImg($jc)\">$h{desc}</a></div>\n";
    $javascript .= "hover[$jc].src=\"$h{menugif}\";\n";
    $jc++;
}
$javascript .= "function onImg(n) { document.images.roller.src=hover[n].src; }
function offImg(n) { document.images.roller.src=\"$conf->{defroller}\"; }
--></script>\n";
# $menutext .= "<tr><td><img src=\"$conf->{defroller}\" id=\"roller\" alt=\"\" /></td></tr>\n</table>\n";
$menutext .= "<div><img src=\"$conf->{defroller}\" id=\"roller\" alt=\"\" /></div>\n</div>\n";
print MENU $javascript, $menutext, "\n";
