package Lingua::CS::Num2Word::Ordinal::Nominative;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Word::Cardinal::Nominative;

our %token1_f = qw(
   0 nultá        1 první         2 druhá
   3 třetí        4 čtvrtá        5 pátá
   6 šestá        7 sedmá         8 osmá
   9 devátá      10 desátá       11 jedenáctá
  12 dvanáctá    13 třináctá     14 čtrnáctá
  15 patnáctá    16 šestnáctá    17 sedmnáctá
  18 osmnáctá    19 devatenáctá
);

our %token1_m = qw(
   0 nultý        1 první         2 druhý
   3 třetí        4 čtvrtý        5 pátý
   6 šestý        7 sedmý         8 osmý
   9 devátý      10 desátý       11 jedenáctý
  12 dvanáctý    13 třináctý     14 čtrnáctý
  15 patnáctý    16 šestnáctý    17 sedmnáctý
  18 osmnáctý    19 devatenáctý
);

our %token1_n = qw(
   0 nulté        1 první         2 druhé
   3 třetí        4 čtvrté        5 páté
   6 šesté        7 sedmé         8 osmé
   9 deváté      10 desáté       11 jedenácté
  12 dvanácté    13 třinácté     14 čtrnácté
  15 patnácté    16 šestnácté    17 sedmnácté
  18 osmnácté    19 devatenácté
);

$token1_f{1} = ['|', 'první', 'prvá'];
$token1_m{1} = ['|', 'první', 'prvý'];
$token1_n{1} = ['|', 'první', 'prvé'];

our %token2_f = qw(
  20 dvacátá     30 třicátá      40 čtyřicátá
  50 padesátá    60 šedesátá     70 sedmdesátá
  80 osmdesátá   90 devadesátá
);

our %token2_m = qw(
  20 dvacátý     30 třicátý      40 čtyřicátý
  50 padesátý    60 šedesátý     70 sedmdesátý
  80 osmdesátý   90 devadesátý
);

our %token2_n = qw(
  20 dvacáté     30 třicáté      40 čtyřicáté
  50 padesáté    60 šedesáté     70 sedmdesáté
  80 osmdesáté   90 devadesáté
);

sub token {
  my ($i, $gender) = @_;
  return {
    f1 => \%token1_f,
    m1 => \%token1_m,
    n1 => \%token1_n,
    f2 => \%token2_f,
    m2 => \%token2_m,
    n2 => \%token2_n,
  }->{$gender.$i};
}

sub get_variants {
  my @result;
  my $number = shift;
  my %opts = @_;
  return () if not defined $number;

  # numbers less than 0 are not supported yet
  return () if $number < 0;

  if (not $opts{gender}) {
    return ['|',
      [get_variants($number, %opts, gender => 'f')],
      [get_variants($number, %opts, gender => 'm')],
      [get_variants($number, %opts, gender => 'n')],
    ];
  }

  my $final = delete $opts{final};
  my $gender = $opts{gender} || 'm';

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
            $Lingua::CS::Num2Word::Cardinal::Nominative::token1_m{$remainder},
            token(2, $gender)->{$tens},
          ],
        ];
      }
    }
  }

  return @result;
}

1;

