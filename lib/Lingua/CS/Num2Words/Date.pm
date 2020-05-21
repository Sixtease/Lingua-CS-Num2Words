package Lingua::CS::Num2Words::Date;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Words::Ordinal::Genitive;
use Lingua::CS::Num2Words::Ordinal::Nominative;
use Lingua::CS::Num2Words::Cardinal::Nominative;

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
  my ($inday, $inmonth, $inyear) = split /\W+/, lc $date_str;

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
  my $explicit_case = '';
  my $explicit_month = '';
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
  if ($inmonth eq $word_months_genitive[$month]) {
    $explicit_month = $inmonth;
    $explicit_case = 'g';
  }
  if ($inmonth eq $word_months_nominative[$month]) {
    $explicit_month = $inmonth;
    if ($explicit_case) {
      $explicit_case = '';
    }
    else {
      $explicit_case = 'n';
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

  my $nom_day = [Lingua::CS::Num2Words::Ordinal::Nominative::get_variants(
      $day, gender => 'm', canonical => 1, final => 1,
  )];
  my $nom_mon = $word_months_nominative[$month];
  my $gen_day = [Lingua::CS::Num2Words::Ordinal::Genitive::get_variants($day, final => 1)];
  my $gen_mon_num = [Lingua::CS::Num2Words::Ordinal::Nominative::get_variants(
      $month, gender => 'm', canonical => 1, final => 1,
  )],
  my $gen_mon_word = $word_months_genitive[$month];

  my @result;
  if ($explicit_case eq 'n') {
    @result = ($nom_day, $explicit_month);
  }
  elsif ($explicit_month) { # explicit genitive or XX. září => implicit genitive
    @result = ($gen_day, $explicit_month);
  }
  elsif ($month == 9) {
    @result = ($gen_day, ['|', $gen_mon_num, $gen_mon_word])
  }
  else {
    @result = ['|',
      [$gen_day, ['|', $gen_mon_num, $gen_mon_word]],
      [$nom_day, $nom_mon],
    ];
  }

  if ($year) {
    push @result, Lingua::CS::Num2Words::Cardinal::Nominative::get_variants(
      $year, final => 1, skip_leading_one => 1,
    );
  }

  return @result;
}

1;
