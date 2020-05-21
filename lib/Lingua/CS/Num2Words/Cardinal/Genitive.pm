package Lingua::CS::Num2Words::Cardinal::Genitive;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Words::Cardinal::Nominative;

our %token1 = qw(
   0 nuly         1 jedné         2 dvou
   3 tří          4 čtyř          5 pěti
   6 šesti        7 sedmi         8 osmi
   9 devíti      10 deseti       11 jedenácti
  12 dvanácti    13 třinácti     14 čtrnácti
  15 patnácti    16 šestnácti    17 sedmnácti
  18 osmnácti    19 devatenácti
);

$token1{1}  = [qw(| jedné jednoho)];
$token1{10} = [qw(| deseti desíti)];

our %token1_f = (%token1, 1 => 'jedné');
our %token1_m = (%token1, 1 => 'jedoho');
our %token1_n = %token1_m;
our %token1_gender = (
  g => \%token1,  # general
  f => \%token1_f,
  m => \%token1_m,
  n => \%token1_n,
);

our %token2 = qw(
  20 dvaceti      30 třiceti       40 čtyřiceti
  50 padesáti     60 šedesáti      70 sedmdesáti
  80 osmdesáti    90 devadesáti
);

our %token3 = (
  100, 'sta',       200, 'dvou set', 300, 'tří set',
  400, 'čtyř set',  500, 'pěti set', 600, 'šesti set',
  700, 'sedmi set', 800, 'osmi set', 900, 'devíti set'
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

  my $final = delete $opts{final};

  if ($number == 0) {
    if ($final) { return $token1{0}; }
    else { return (); }
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
        my $nom_units = $Lingua::CS::Num2Words::Cardinal::Nominative::token1_m{$remainder};
        @result = [
          '|',
          [$token2{$tens}, get_variants($remainder, %opts)],
          [join 'a', $nom_units, $token2{$tens}],
        ];
      }
    }
  } elsif ($number < 1_000) {
    $remainder = $number % 100;
    if ($remainder != 0) {
      if ($number < 200) {
        @result = ($Lingua::CS::Num2Words::Cardinal::Nominative::token3{$number - $remainder}, get_variants($remainder, %opts));
      }
      else {
        @result = (
          ['|', $Lingua::CS::Num2Words::Cardinal::Nominative::token3{$number - $remainder}, $token3{$number - $remainder}],
          get_variants($remainder, %opts),
        );
      }
    } elsif ($final or $remainder == 0) {
      @result = [$token3{$number}];
    } else {
      @result = [$Lingua::CS::Num2Words::Cardinal::Nominative::token3{$number}];
    }
  } elsif ($number < 20_000) {
    $remainder = $number % 1_000;
    my $tmp2 = int ($number / 1000);  # number of thousands
    my $tmp3 = $tmp2 % 100;         # number of tens of thousands
    my $tmp4 = $tmp2 % 10;          # number of single thousands

    if ($number == 1000) {
      @result = ['|', 'tisíce', 'jednoho tisíce'];
    } elsif ($tmp4 == 1 && $tmp2 == 1 && $remainder >= 100) {
      my $hundreds = int ($remainder / 100);
      my $tens = $remainder % 100;

      my @nom1K = $remainder > 0 ? ('tisíc', 'jeden tisíc') : ();
      my @teenhundred = [[map { [$_, 'set'] } get_variants(10 + $hundreds)], get_variants($tens)];
      my @thousandhundred = [['|', @nom1K, 'tisíce', 'jednoho tisíce'], get_variants($remainder)];

      $remainder = 0;

      @result = (['|', @teenhundred, @thousandhundred], );
    } elsif ($tmp4 == 1 && $tmp2 == 1) {
      @result = ['|', 'tisíc', 'tisíce', 'jednoho tisíce'];
    } elsif ($tmp4 == 1 && $tmp3 > 19) {
      @result = ['|',
        [get_variants($tmp2), 'tisíc'],
        [get_variants($tmp2 - $tmp4), 'jednoho tisíce'],
        [Lingua::CS::Num2Words::Cardinal::Nominative::get_variants(1000 * $tmp2)],
      ];
    } elsif ($tmp2 > 1 && $tmp2 < 5 && $remainder > 0) {
      @result = ['|',
        [get_variants($tmp2), 'tisíc'],
        [Lingua::CS::Num2Words::Cardinal::Nominative::get_variants($tmp2), 'tisíce'],
      ];
    } elsif ($remainder > 0) {
      @result = (['|',
        [get_variants($tmp2)],
        [Lingua::CS::Num2Words::Cardinal::Nominative::get_variants($tmp2)],
      ], 'tisíc');
    } else {
      @result = (get_variants($tmp2), 'tisíc');
    }

    if ($remainder != 0) {
      push @result, get_variants($remainder);
    }

  } else {
    # >= 20000 unsupported yet
  }

  return @result;
}

1;
