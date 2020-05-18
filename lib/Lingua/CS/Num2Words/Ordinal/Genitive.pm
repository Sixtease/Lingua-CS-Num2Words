package Lingua::CS::Num2Words::Ordinal::Genitive;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Words::Cardinal::Nominative;

our %token1_m = qw(
   0 nultého      1 prvního       2 druhého
   3 třetího      4 čtvrtého      5 pátého
   6 šestého      7 sedmého       8 osmého
   9 devátého    10 desátého     11 jedenáctého
  12 dvanáctého  13 třináctého   14 čtrnáctého
  15 patnáctého  16 šestnáctého  17 sedmnáctého
  18 osmnáctého  19 devatenáctého
);

our %token2_m = qw(
  20 dvacátého   30 třicátého    40 čtyřicátého
  50 padesátého  60 šedesátého   70 sedmdesátého
  80 osmdesátého 90 devadesátého
);

sub token {
  my ($i) = @_;
  return {
    1 => \%token1_m,
    2 => \%token2_m,
  }->{$i};
}

sub get_variants {
  my @result;
  my $number = shift;
  my %opts = @_;
  return () if not defined $number;

  # numbers less than 0 are not supported yet
  return () if $number < 0;

  my $final = delete $opts{final};

  my $gender = 'm'; # others not supported atm

  if ($number == 0 and not $final) {
    return ();
  }

  my $remainder = 0;

  if ($number < 20) {
    @result = token(1, $gender)->{$number};
  } elsif ($number < 100) {
    $remainder = $number % 10;
    if ($remainder == 0) {
      @result = token(2, $gender)->{$number};
    } else {
      my $tens = $number - $remainder;
      if (delete $opts{skip_german_style}) {
        @result = [token(2, $gender)->{$tens}, get_variants($remainder, %opts)];
      }
      else {
        @result = [
          '|',
          [token(2, $gender)->{$tens}, get_variants($remainder, %opts)],
          [join 'a',
            $Lingua::CS::Num2Words::Cardinal::Nominative::token1_m{$remainder},
            token(2, $gender)->{$tens},
          ],
        ];
      }
    }
  }

  return @result;
}

1;

