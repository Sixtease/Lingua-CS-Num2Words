# For Emacs: -*- mode:cperl; mode:folding; coding:iso-8859-2; -*-
#
# (c) 2002-2004 PetaMem, s.r.o.
#
# PPCG: 0.7
#

package Lingua::CS::Num2Word;

# {{{ use block

use strict;
use utf8;
use open qw(:std :utf8);
use 5.010;

# }}}

# {{{ BEGIN

BEGIN {
  use Exporter ();
  use vars qw($VERSION $REVISION @ISA @EXPORT_OK);
  $VERSION    = 0.03;
  ($REVISION) = '$Revision: 1.14 $' =~ /([\d.]+)/;
  @ISA        = qw(Exporter);
  @EXPORT_OK  = qw(&num2cs_cardinal);
}

# }}}

# {{{ variables

my %token1 = qw(
   0 nula         1 jedna         2 dva
   3 tři          4 čtyři         5 pět
   6 šest         7 sedm          8 osm
   9 devět       10 deset        11 jedenáct
  12 dvanáct     13 třináct      14 čtrnáct
  15 patnáct     16 šestnáct     17 sedmnáct
  18 osmnáct     19 devatenáct
);

my %token2 = qw(
  20 dvacet      30 třicet       40 čtyřicet
  50 padesát     60 šedesát      70 sedmdesát
  80 osmdesát    90 devadesát
);

my %token3 = (
  100, 'sto',       200, 'dvě stě',   300, 'tři sta',
  400, 'čtyři sta', 500, 'pět set',   600, 'šest set',
  700, 'sedm set',  800, 'osm set',   900, 'devět set'
);

# }}}

# {{{ num2cs_cardinal           number to string conversion

sub get_variants {
  my @result;
  my $number = shift;
  return () if not defined $number;

  # numbers less than 0 are not supported yet
  return () if $number < 0;

  my $remainder = 0;

  if ($number < 20) {
    @result = [$token1{$number}];
  } elsif ($number < 100) {
    $remainder = $number % 10;
    if ($remainder == 0) {
      @result = [$token2{$number}];
    } else {
      @result = ([$token2{$number - $remainder}], get_variants($remainder));
    }
  } elsif ($number < 1_000) {
    $remainder = $number % 100;
    if ($remainder != 0) {
      @result = ([$token3{$number - $remainder}], get_variants($remainder));
    } else {
      @result = [$token3{$number}];
    }
  } elsif ($number < 1_000_000) {
    $remainder = $number % 1_000;
    my $tmp2 = substr($number, 0, length($number)-3);  # number of thousands
    my $tmp3 = $tmp2 % 100;                            # number of tens of thousands
    my $tmp4 = $tmp2 % 10;                             # number of single thousands

    if ($tmp3 < 9 || $tmp3 > 20) {

      if ($tmp4 == 1 && $tmp2 == 1 && $remainder >= 100) {
        my $hundreds = int ($remainder / 100);
        $remainder = $remainder % 100;

        my @teenhundred = map { $_ . ' set' } map { @$_ } get_variants(10 + $hundreds);
        my @thousandhundred = map { 'tisíc ' . $_ } map { @$_ } get_variants(100 * $hundreds);

        @result = [@teenhundred, @thousandhundred];
      } elsif ($tmp4 == 1 && $tmp2 == 1) {
        @result = ['tisíc'];
      } elsif ($tmp4 == 1) {
        @result = (get_variants($tmp2 - $tmp4), ['jeden tisíc']);
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2), ['tisíce']);
      } else {
        @result = (get_variants($tmp2), ['tisíc']);
      }
    } else {
      @result = (get_variants($tmp2), ['tisíc']);
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } elsif ($number < 1_000_000_000) {
    $remainder = $number % 1_000_000;
    my $tmp2 = substr($number, 0, length($number)-6);
    my $tmp3 = $tmp2 % 100;
    my $tmp4 = $tmp2 % 10;

    if ($tmp3 < 9 || $tmp3 > 20) {

      if ($tmp4 == 1 && $tmp2 == 1) {
        @result = ['milion'];
      } elsif ($tmp4 == 1) {
        @result = (get_variants($tmp2 - $tmp4), ['jeden milion']);
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2), ['miliony']);
      } else {
        @result = (get_variants($tmp2), ['milionů']);
      }
    } else {
      @result = (get_variants($tmp2), ['milionů']);
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } elsif ($number < 1e12) {
    $remainder = $number % 1e9;
    my $tmp2 = substr($number, 0, length($number)-9);
    my $tmp3 = $tmp2 % 100;
    my $tmp4 = $tmp2 % 10;

    if ($tmp3 < 9 || $tmp3 > 20) {

      if ($tmp4 == 1 && $tmp2 == 1) {
        @result = ['miliarda'];
      } elsif ($tmp4 == 1) {
        @result = (get_variants($tmp2 - $tmp4), ['jedna miliarda']);
      } elsif ($tmp4 == 2) {
        @result = ['dvě miliardy'];
        if ($tmp2 > 2) {
          unshift @result, get_variants($tmp2 - $tmp4);
        }
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2), ['miliardy']);
      } else {
        @result = (get_variants($tmp2), ['miliard']);
      }
    } else {
      @result = (get_variants($tmp2), ['miliard']);
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } else {
    # >= 1 000 000 000 unsupported yet (miliard)
  }

  return @result;
}

sub unfold {
  my @acc;
  my @cur = @{ shift() };
  if (@_ == 0) {
    return @cur;
  }
  for my $head (@cur) {
    for my $tail (unfold(@_)) {
      push @acc, join ' ', $head, $tail;
    }
  }
  return @acc;
}

sub num2cs_cardinal {
  my $num = shift;
  my @variants = get_variants($num);
  # use Data::Dumper; print(Dumper(\@variants));
  return unfold @variants;
}

# }}}

1;
__END__

# {{{ documentation

=head1 NAME

Lingua::CS::Num2Word -  number to text convertor for czech. Output
text is in iso-8859-2 encoding.

=head1 SYNOPSIS

 use Lingua::CS::Num2Word;

 my $text = Lingua::CS::Num2Word::num2cs_cardinal( 123 );

 print $text || "sorry, can't convert this number into czech language.";

=head1 DESCRIPTION

Lingua::CS::Num2Word is module for convertion numbers into their representation
in czech. Converts whole numbers from 0 up to 999 999 999.

=head2 Functions

=over

=item * num2cs_cardinal(number)

Convert number to text representation.

=back

=head1 EXPORT_OK

num2cs_cardinal

=head1 KNOWN BUGS

None.

=head1 AUTHOR

Roman Vasicek E<lt>rv@petamem.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2002-2004 PetaMem s.r.o. - L<http://www.petamem.com/>

This package is free software. You can redistribute and/or modify it under
the same terms as Perl itself.

=cut

# }}}
