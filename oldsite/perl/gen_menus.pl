#!/usr/psr/bin/perl
use strict;
use warnings;
use lib '/u/isg/perllib';
use YAML qw/LoadFile/;
use CGI qw/-no_debug :standard/;

use Getopt::Long;
Getopt::Long::Configure(qw/bundling/);
my  ( $menucolor, $heading, $menufile, $images,   $class ) =
    (  '#ff9900',       '',        '',       0,  'menu_' );
my  (                  $corner, $debug,             $debug_img, $img_size ) =
    ( '../pics/whitesolid.gif',      0, '../pics/testicon.gif',        48 );
my  ( $topmargin,  $bgcolor, $corner_size ) =
    (          5, '#ffffff',           20 );
GetOptions( 'images|i'      => \$images,
            'title|t=s'     => \$heading,
            'menu|mf|m=s'   => \$menufile,
            'debug|d'       => \$debug,
            'corner|ci=s'   => \$corner,
            'classpre|P=s'  => \$class,
            'di=s'          => \$debug_img,
            'isize|I=i'     => \$img_size,
            'csize|C=i'     => \$corner_size,
            'topmargin|T=i' => \$topmargin,
            'bgcolor|b=s'   => \$bgcolor,
            'menucolor|c=s' => \$menucolor )
    or die 'USAGE';
my $c = qr/([A-Fa-f0-9])/;
$bgcolor   =~ s/$c/$1$1/g if $bgcolor   =~ /^$c$c$c$/;
$menucolor =~ s/$c/$1$1/g if $menucolor =~ /^$c$c$c$/;

$bgcolor   = '#'.lc($bgcolor  ) if $bgcolor   =~ /^(?:$c){6}$/;
$menucolor = '#'.lc($menucolor) if $menucolor =~ /^(?:$c){6}$/;

die '-m file ( == -m main )' unless $menufile;
die '-t title ( == -tMenu_Head )' unless $heading;
$heading =~ tr/_/ /;

my $filename = "lists/$menufile.list";
my @items = @{LoadFile($filename)};

my $att0 = { cellpadding => 0,
             cellspacing => 0,
             border      => 0 };
my $att1 = { %$att0, width => 200    };
my $att2 = { %$att0, width => '100%' };
my $att4 = { %$att2, cellpadding => 2 };
my $att3 = { %$att4, valign => 'top' };

my $padding = Tr(td({ height => $topmargin,
                      class  => $class.'filler' },
                    ' ' ))."\n";
my $menu = '';
foreach my $hash (@items) {
    my ($url, $text, $img,
    $img = $debug_img if $debug;
    $menu .= $padding unless $images;
    $menu .=
        Tr(td( { bgcolor => $bgcolor },
               table($att0, Tr( (($images)
                                 ? td( { width  => $img_size,
                                         height => $img_size },
                                       img( { src    => $img,
                                              width  => $img_size,
                                              height => $img_size,
                                              border => 0 } ) )
                                 : '') .
                                td( { class => $class.'item' },
                                    a( { href => $url },
                                       $text ) )
                                ))
               )) . "\n";
}

$filename =~ s|^(?:.*/)?(\w+)(?:\.\w+)?$|html/${1}menu.html|;
open STDOUT, '>', $filename or die "$filename: $!";

print
table($att1, Tr(td( { class => 'menu' },
#                    ))); #delete (just for tabbing)
table($att2, Tr( td( { width   => $corner_size,
                       valign  => 'top',
                       align   => 'left',
                       bgcolor => $menucolor,
                       class   => $class.'headpad' },
                     img( { src    => $corner,
                            width  => $corner_size,
                            height => $corner_size,
                            border => 0 } ) ).
                 td( { align   => 'center',
                       bgcolor => $menucolor,
                       class   => $class.'head',
                       height  => $corner_size },
                     $heading ).
                 td( { align   => 'right',
                       bgcolor => $menucolor,
                       class   => $class.'headpad',
                       width   => $corner_size },
                     '&nbsp;' ) ) ) . "\n" .
#    ; # delete (tabbing)
table($att3, Tr(td( { bgcolor => $menucolor },
#                    ))); # tabbing
table($att2, Tr( td( { bgcolor => $bgcolor,
                       width   => '6%' }, '&nbsp;' ).
                 td( { bgcolor => $bgcolor,
                       width   => '94%' },
#                     ))); # tabbing
                     table($att4, $padding . $menu . $padding))))))))));
