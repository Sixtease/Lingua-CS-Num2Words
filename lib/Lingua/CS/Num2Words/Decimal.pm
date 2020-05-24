package Lingua::CS::Num2Words::Decimal;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Words::Cardinal::Nominative;

sub get_variants {
  my $number = shift;
  my %opts = @_;
  return () if not defined $number;

  # numbers less than 0 are not supported yet
  return () if $number < 0;

  my ($int, $frac) = split /,/, $number;
  $frac =~ s/^(0*)//;
  my $frac0 = [('nula') x length $1];

  my $comma;
  if ($int == 0 or $int == 1) {
    $comma = 'celá';
  }
  elsif ($int >= 2 and $int <= 4) {
    $comma = 'celé';
  }
  else {
    $comma = 'celých';
  }

  my @genderopt = $int < 10 ? (gender => 'f') : ();
  my @intw = Lingua::CS::Num2Words::Cardinal::Nominative::get_variants(
    $int, final => 1, @genderopt,
  );

  my @fracw = Lingua::CS::Num2Words::Cardinal::Nominative::get_variants($frac, final => 1);

  # nula celá jedna dva tři
  if (length $frac > 1) {
    my @numeral_frac = @fracw;
    my @digital_frac = (map
      $Lingua::CS::Num2Words::Cardinal::Nominative::token1{$_},
      split //, $frac,
    );
    @fracw = ['|',
      [@numeral_frac],
      [@digital_frac],
    ];
  }

  my $rv = [
    @intw,
    $comma,
    $frac0,
    @fracw,
  ];
  #  use Data::Dumper; print(Dumper($rv));

  if (@$frac0 == 0 and $frac == 5) {
    return ['|',
      $rv,
      [
        Lingua::CS::Num2Words::Cardinal::Nominative::get_variants(
          $int, final => 1, %opts,
        ),
        'a půl',
      ],
    ];
  }
  else {
    return $rv;
  }
}

1;
