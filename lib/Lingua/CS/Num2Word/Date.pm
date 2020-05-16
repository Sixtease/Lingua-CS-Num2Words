package Lingua::CS::Num2Word::Date;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Word::Ordinal::Genitive;
use Lingua::CS::Num2Word::Ordinal::Nominative;
use Lingua::CS::Num2Word::Cardinal::Nominative;

my @word_months_nominative = ('', qw(
  leden  únor   březen   duben
  květen červen červenec srpen
  září   říjen  listopad prosinec
));

my @word_months_genitive = ('', qw(
  ledna  února  března    dubna
  května června července  srpna
  září   října  listopadu prosince
));

sub get_variants {
  my ($date_str) = @_;

  $date_str =~ s/^\W+//;
  $date_str =~ s/\W+$//;
  my ($inday, $inmonth, $inyear) = split /\W+/, $date_str;

  if (not $inday or not $inmonth) {
    warn "Unexpected date format: '$date_str'";
    return ();
  }

  my $day = int $inday;
  unless ($day >= 1 and $inday <= 31) {
    warn "Unexpected day of month: '$inday'";
    return ();
  }

  my $month;
  if ($inmonth >= 1 and $inmonth <= 12) {
    $month = int $inmonth;
  }
  elsif ($inmonth =~ /č.*c/) {
    $month = 7;
  }
  elsif ($inmonth =~ /č/) {
    $month = 6;
  }
  else {
    for my $i (1 .. 12) {
      if (substr($inmonth, 0, 2) eq substr($word_months_nominative[$i], 0, 2)) {
        $month = $i;
        last;
      }
    }
  }
  if (not $month) {
    warn "Unexpected month: '$inmonth'"
  }

  my $year;
  if ($inyear > 20 and $inyear <= 99 or $inyear > 1000) {
    $year = int $inyear;
  }
  elsif ($inyear) {
    warn "Unexpected year: '$inyear'";
    return ();
  }

  my @result = ['|',
    [
      [Lingua::CS::Num2Word::Ordinal::Genitive::get_variants($day, final => 1)],
      ['|',
        [Lingua::CS::Num2Word::Ordinal::Nominative::get_variants($month, gender => 'm', canonical => 1, final => 1)],
        [$word_months_genitive[$month]],
      ],
    ],
    [
      [Lingua::CS::Num2Word::Ordinal::Nominative::get_variants($day, gender => 'm', canonical => 1, final => 1)],
      [$word_months_nominative[$month]],
    ],
  ];

  if ($year) {
    push @result, [Lingua::CS::Num2Word::Cardinal::Nominative::get_variants($year, final => 1, skip_leading_one => 1)];
  }

  return @result;
}

1;
