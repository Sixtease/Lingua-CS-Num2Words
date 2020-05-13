# For Emacs: -*- mode:cperl; mode:folding; coding:iso-8859-2; -*-
#
# (c) 2002-2004 PetaMem, s.r.o.
#
# PPCG: 0.7
#

=head1 NAME

Lingua::CS::Num2Word - pronunciation variants for Czech numerals.

=head1 SYNOPSIS

 use Lingua::CS::Num2Word;

 my @variants = Lingua::CS::Num2Word::num2cs_cardinal( 123 );

 print 'you can cay 123 like this in Czech: ', join(', ', @variants);

=head1 DESCRIPTION

Lingua::CS::Num2Word is module for convertion numbers into their representation
in czech. Converts whole numbers from 0 up to 999 999 999.

=head2 Functions

=over
=cut

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
  $VERSION    = 2.01;
  ($REVISION) = '$Revision: 0.01 $' =~ /([\d.]+)/;
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

my %token1_m = (%token1, 1 => 'jeden');
my %token1_f = (%token1, 2 => 'dvě');
my %token1_n = (%token1_f, 1 => 'jedno');
my %token1_gender = (
  g => \%token1,  # general
  f => \%token1_f,
  m => \%token1_m,
  n => \%token1_n,
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

=item get_variants(1234)

return a data structure describing the variants, in this example

  (
    ['|', ['dvanáct', 'set'], ['tisíc', ['dvě stě']]],
    ['|', ['třicet', 'čtyři'], ['čtyřiatřicet']]
  )

A list starting with C<'|'> represents alternatives, other lists represent concatenation.

=cut

sub get_variants {
  my @result;
  my $number = shift;
  my %opts = @_;
  return () if not defined $number;

  # numbers less than 0 are not supported yet
  return () if $number < 0;

  # false if called recursively as a part of greater number
  if ($opts{final}) {
    if ($number == 1) {
      return (['|', 'jeden', 'jedna', 'jedno']);
    }
    if ($number == 2) {
      return (['|', 'dva', 'dvě']);
    }
    delete $opts{final};  # don't pass this
  }

  my $remainder = 0;

  if ($number < 20) {
    @result = $token1_gender{$opts{gender} || 'g'}{$number};
  } elsif ($number < 100) {
    $remainder = $number % 10;
    if ($remainder == 0) {
      @result = $token2{$number};
    } else {
      my $tens = $number - $remainder;
      if ($opts{skip_german_style}) {
        @result = [$token2{$tens}, get_variants($remainder)];
      }
      else {
        @result = [
          '|',
          [$token2{$tens}, get_variants($remainder)],
          [join 'a', $token1_m{$remainder}, $token2{$tens}],
        ];
      }
    }
  } elsif ($number < 1_000) {
    $remainder = $number % 100;
    if ($remainder != 0) {
      @result = ([$token3{$number - $remainder}], get_variants($remainder, %opts));
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

        my @teenhundred = map { [$_, 'set'] } get_variants(10 + $hundreds);
        my @thousandhundred = map {
          [['|', 'tisíc', 'jeden tisíc'], $_]
        } get_variants(100 * $hundreds);

        @result = ['|', @teenhundred, @thousandhundred];
      } elsif ($tmp4 == 1 && $tmp2 == 1) {
        @result = ['|', 'tisíc', 'jeden tisíc'];
      } elsif ($tmp4 == 1) {
        @result = ['|',
          [get_variants($tmp2), 'tisíc'],
          [get_variants($tmp2 - $tmp4), 'jeden tisíc'],
        ];
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = ['|',
          [get_variants($tmp2), 'tisíc'],
          [get_variants($tmp2, skip_german_style => 1), 'tisíce'],
        ];
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
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2, gender => 'f'), ['miliardy']);
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

sub proc {
  my $acc = shift;
  if ($_[0] eq '|') {
    shift;
    alt($acc, @_);
  }
  else {
    seq($acc, @_);
  }
}

=item seq

unfolds and concatenates items in a list

=cut

sub seq {
  my $acc = shift;
  for my $item (@_) {
    if (ref $item) {
      proc($acc, @$item);
    }
    else {
      for my $branch (@$acc) {
        push @$branch, $item;
      }
    }
  }
}

=item alt

add variants to accumulator

with B branches in the accumulator and N items as parameters,
unfolds all N items and makes N copies of every branch, appending
an item to each copy

=cut

sub alt {
  my $acc = shift;
  my @cur_acc = @$acc;
  my @new_acc;
  for my $item (@_) {
    my @unfolded_item = unfold($item);
    for my $unfolded_item (@unfolded_item) {
      for my $branch (@cur_acc) {
        push @new_acc, [@$branch, @$unfolded_item];
      }
    }
  }
  @$acc = @new_acc;
}

=item unfold

input:

  (
    ['|', ['dvanáct', 'set'], ['tisíc', ['dvě stě']]],
    ['|', ['třicet', 'čtyři'], ['čtyřiatřicet']],
  )

output:

  (
    ['dvanáct', 'set', 'třicet', 'čtyři'],
    ['dvanáct', 'set', 'čtyřiatřicet'],
    ['tisíc', 'dvě stě', 'třicet', 'čtyři'],
    ['tisíc', 'dvě stě', 'čtyřiatřicet'],
  )
=cut
sub unfold {
  my $acc = [[]];
  proc($acc, @_);
  return @$acc;
}

=item flatten

input: C<(['raz', 'dva'], ['tři', 'čtyři])>,
output: C<(['raz dva'], ['tři čtyři'])>

=cut

sub flatten {
  return map { join ' ', @$_ } @_;
}

=item num2cs_cardinal

return a list of pronunciation variants for given number

=cut

sub num2cs_cardinal {
  my $num = shift;
  my @variants = get_variants($num, final => 1);
  #use Data::Dumper; print(Dumper(@variants));
  my @unfolded = unfold @variants;
  return flatten(@unfolded);
}

# }}}

1;
__END__

# {{{ documentation

=back

=head1 EXPORT_OK

num2cs_cardinal

=head1 AUTHOR

Based on Lingua::CS::Num2Word by Roman Vasicek E<lt>rv@petamem.comE<gt>
adapted by Jan Oldřich Krůza of Konica Minolta E<lt><jan.kruza@konicaminolta.czE<gt>

=head1 COPYRIGHT

Copyright (c) 2002-2004 PetaMem s.r.o.
Copyright (c) 2020 Konica Minolta

This package is free software. You can redistribute and/or modify it under
the same terms as Perl itself.

=cut

# }}}
