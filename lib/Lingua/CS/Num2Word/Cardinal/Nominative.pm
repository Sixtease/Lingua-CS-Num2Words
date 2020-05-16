package Lingua::CS::Num2Word::Cardinal::Nominative;

use utf8;
use strict;
use 5.010;

our %token1 = qw(
   0 nula         1 jedna         2 dva
   3 tři          4 čtyři         5 pět
   6 šest         7 sedm          8 osm
   9 devět       10 deset        11 jedenáct
  12 dvanáct     13 třináct      14 čtrnáct
  15 patnáct     16 šestnáct     17 sedmnáct
  18 osmnáct     19 devatenáct
);

our %token1_m = (%token1, 1 => 'jeden');
our %token1_f = (%token1, 2 => 'dvě');
our %token1_n = (%token1_f, 1 => 'jedno');
our %token1_gender = (
  g => \%token1,  # general
  f => \%token1_f,
  m => \%token1_m,
  n => \%token1_n,
);

our %token2 = qw(
  20 dvacet      30 třicet       40 čtyřicet
  50 padesát     60 šedesát      70 sedmdesát
  80 osmdesát    90 devadesát
);

our %token3 = (
  100, 'sto',       200, 'dvě stě',   300, 'tři sta',
  400, 'čtyři sta', 500, 'pět set',   600, 'šest set',
  700, 'sedm set',  800, 'osm set',   900, 'devět set'
);

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
  if (delete $opts{final}) {
    if ($number == 1) {
      return (['|', 'jeden', 'jedna', 'jedno']);
    }
    if ($number == 2) {
      return (['|', 'dva', 'dvě']);
    }
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
      if (delete $opts{skip_german_style}) {
        @result = [$token2{$tens}, get_variants($remainder, %opts)];
      }
      else {
        @result = [
          '|',
          [$token2{$tens}, get_variants($remainder, %opts)],
          [join 'a', $token1_m{$remainder}, $token2{$tens}],
        ];
      }
    }
  } elsif ($number < 1_000) {
    $remainder = $number % 100;
    if ($remainder != 0) {
      @result = ($token3{$number - $remainder}, get_variants($remainder, %opts));
    } else {
      @result = $token3{$number};
    }
  } elsif ($number < 1_000_000) {
    $remainder = $number % 1_000;
    my $tmp2 = int ($number / 1000);  # number of thousands
    my $tmp3 = $tmp2 % 100;           # number of tens of thousands
    my $tmp4 = $tmp2 % 10;            # number of single thousands
    my $thousandprefix = $opts{skip_leading_one} ? 'tisíc' : ['|', 'tisíc', 'jeden tisíc'];

    if ($tmp3 < 9 || $tmp3 > 20) {

      if ($tmp4 == 1 && $tmp2 == 1 && $remainder >= 100) {
        my $hundreds = int ($remainder / 100);
        $remainder = $remainder % 100;

        my @teenhundred = map { [$_, 'set'] } get_variants(10 + $hundreds);
        my @thousandhundred = map {
          [$thousandprefix, $_]
        } get_variants(100 * $hundreds);

        @result = ['|', @teenhundred, @thousandhundred];
      } elsif ($tmp4 == 1 && $tmp2 == 1) {
        @result = $thousandprefix;
      } elsif ($tmp4 == 1) {
        @result = ['|',
          [get_variants($tmp2), 'tisíc'],
          [get_variants($tmp2 - $tmp4), 'jeden tisíc'],
        ];
      } elsif($tmp4 > 1 && $tmp4 < 5 && $tmp2 > $tmp4) {
        @result = ['|',
          [get_variants($tmp2), 'tisíc'],
          [get_variants($tmp2, skip_german_style => 1), 'tisíce'],
        ];
      } elsif ($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2), 'tisíce');
      } else {
        @result = (get_variants($tmp2), 'tisíc');
      }
    } else {
      @result = (get_variants($tmp2), 'tisíc');
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } elsif ($number < 1_000_000_000) {
    $remainder = $number % 1_000_000;
    my $tmp2 = int ($number / 1_000_000);
    my $tmp3 = $tmp2 % 100;
    my $tmp4 = $tmp2 % 10;

    if ($tmp3 < 9 || $tmp3 > 20) {

      if ($tmp4 == 1 && $tmp2 == 1 && $opts{skip_leading_one}) {
        @result = 'milion';
      } elsif ($tmp4 == 1 && $tmp2 == 1) {
        @result = ['|', 'milion', 'jeden milion'];
      } elsif ($tmp4 == 1) {
        @result = ['|',
          [get_variants($tmp2), 'milionů'],
          [get_variants($tmp2 - $tmp4), 'jeden milion'],
        ];
      } elsif($tmp4 > 1 && $tmp4 < 5 && $tmp2 > $tmp4) {
        @result = ('|',
          [get_variants($tmp2), 'milionů'],
          [get_variants($tmp2, skip_german_style => 1), 'miliony'],
        );
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2), 'miliony'),
      } else {
        @result = (get_variants($tmp2), 'milionů');
      }
    } else {
      @result = (get_variants($tmp2), 'milionů');
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } elsif ($number < 1e12) {
    $remainder = $number % 1e9;
    my $tmp2 = int ($number / 1e9);
    my $tmp3 = $tmp2 % 100;
    my $tmp4 = $tmp2 % 10;

    if ($tmp3 < 9 || $tmp3 > 20) {

      if ($tmp4 == 1 && $tmp2 == 1 && $opts{skip_leading_one}) {
        @result = 'miliarda';
      } elsif ($tmp4 == 1 && $tmp2 == 1) {
        @result = ['|', 'miliarda', 'jedna miliarda'];
      } elsif ($tmp4 == 1) {
        @result = ['|',
          [get_variants($tmp2), ['miliard']],
          [get_variants($tmp2 - $tmp4), ['jedna miliarda']],
        ];
      } elsif($tmp4 > 1 && $tmp4 < 5 && $tmp2 > $tmp4) {
        @result = ['|',
          [get_variants($tmp2), ['miliard']],
          [get_variants($tmp2, gender => 'f', skip_german_style => 1), ['miliardy']],
        ];
      } elsif($tmp4 > 1 && $tmp4 < 5) {
        @result = (get_variants($tmp2, gender => 'f'), 'miliardy')
      } else {
        @result = (get_variants($tmp2), 'miliard');
      }
    } else {
      @result = (get_variants($tmp2), 'miliard');
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } else {
    # >= 1 000 000 000 unsupported yet (bilion)
  }

  return @result;
}

1;
