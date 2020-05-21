package Lingua::CS::Num2Words::Time;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Words::Cardinal::Nominative;
use Lingua::CS::Num2Words::Cardinal::Genitive;
use Lingua::CS::Num2Words::Cardinal::Accusative;

our %token_hour_genitive = (
  %Lingua::CS::Num2Words::Ordinal::Genitive::token1_f,
  1 => 'jedné',
);

sub get_variants {
  my ($time_str, %opts) = @_;

  my %case = (n => 1, g => 1, a => 1);
  if ($opts{case}) {
    %case = ($opts{case} => 1);
  }

  $time_str =~ s/^\W+//;
  $time_str =~ s/\W+$//;
  my ($inhour, $inminute) = split /\W+/, lc $time_str;

  if (not defined $inhour or not defined $inminute) {
    warn "Unexpected time format: '$time_str'";
    return ();
  }

  my $hour = int $inhour;
  if ($hour > 24) {
    warn "Unexpected hour: '$inhour'";
    return ();
  }

  my $minute = int $inminute;
  if ($minute >= 60) {
    warn "Unexpected minute: '$inminute'";
    return ();
  }

  if ($hour == 0 and $minute == 0) {
    return ['|',
      'půlnoc',
      'půlnoci',
      'dvacet čtyři hodin',
      'nula hodin nula minut',
      'dvanáct nula nula',
      'dvanácti nula nula',
    ];
  }

  my @result = ('|');

  my @civil;
  if ($minute % 15 == 0) {
    my $next_hour = $hour % 12 + 1;
    if ($minute % 30 != 0) {
      push(@civil,
        ($minute == 15 ? 'čtvrt' : 'tři čtvrtě'), 'na',
        $Lingua::CS::Num2Words::Cardinal::Accusative::token1_f{$next_hour},
      );
    }
    elsif ($minute == 30) {
      push(@civil, 'půl', $token_hour_genitive{$next_hour});
    }
  }
  push @result, \@civil if @civil;

  my @plain_hour = Lingua::CS::Num2Words::Cardinal::Nominative::get_variants($hour, final => 1, gender => 'f');
  my @num_hour = $hour > 0 ? @plain_hour : 'nula nula';
  my @plain_minute = Lingua::CS::Num2Words::Cardinal::Nominative::get_variants($minute, final => 1, gender => 'g');
  if ($minute == 2) {
    @plain_minute = ['|', 'dvě', 'dva'];
  }
  my @zero_minute = @plain_minute;
  if ($minute < 10) {
    unshift @zero_minute, 'nula';
  }
  if ($minute == 0) {
    @zero_minute = 'nula nula';
  }
  my @pure_num_nom = (
    @num_hour,
    @zero_minute,
  );
  push @result, \@pure_num_nom if $case{n} or $case{a};

  my $lithour = 'hodin';
  my $litmin = 'minut';
  if ($minute <= 4) {
    $litmin = 'minuty';
  }
  if ($minute == 1) {
    $litmin = ['|', 'jedna minuta', 'jednu minutu'];
    @plain_minute = ();
  }
  if ($minute == 0) {
    $litmin = ['|', 'nula nula', 'nula minut', ''];
    @plain_minute = ();
  }
  if ($case{n} or $case{a}) {
    if ($hour == 0) {
      push @result, ['nula hodin', @plain_minute, $litmin]
    }
    elsif ($hour == 1) {
      push @result, [['|', 'jedna hodina', 'jednu hodinu'], @plain_minute, $litmin];
    }
    elsif ($hour <= 4) {
      push @result, [@plain_hour, 'hodiny', @plain_minute, $litmin];
    }
    else {
      push @result, [@plain_hour, $lithour, @plain_minute, $litmin];
    }
  }

  @plain_hour = Lingua::CS::Num2Words::Cardinal::Genitive::get_variants($hour, final => 1, gender => 'f');
  @plain_minute = Lingua::CS::Num2Words::Cardinal::Genitive::get_variants($minute, final => 1, gender => 'g');

  if ($hour == 0) {
    @plain_hour = 'nula nula';
  }
  if ($minute == 0) {
    @plain_minute = 'nula';
  }
  if ($minute == 1) {
    @plain_minute = 'jedné minuty';
  }
  if ($minute >= 10) {
    @zero_minute = @plain_minute;
  }
  my @pure_num_gen = (
    @plain_hour,
    @zero_minute,
  );
  push @result, \@pure_num_gen if $case{g};

  if ($hour == 0) {
    @plain_hour = 'nula';
    $lithour = 'hodin';
  }
  elsif ($hour == 1) {
    @plain_hour = 'jedné';
    $lithour = 'hodiny';
  }
  else {
    $lithour = 'hodin';
  }
  $litmin = $minute == 1 ? 'minuty' : 'minut';
  push @result, [@plain_hour, $lithour, @plain_minute, $litmin] if $case{g};

  return \@result;
}

1;

