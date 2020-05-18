=head1 NAME

Lingua::CS::Num2Words - pronunciation variants for Czech numerals.

=head1 SYNOPSIS

 use Lingua::CS::Num2Words;

 my @variants = Lingua::CS::Num2Words::num2cs_cardinal( 123 );

 print 'you can cay 123 like this in Czech: ', join(', ', @variants);

=head1 DESCRIPTION

Based on Lingua::CS::Num2Word by Roman Vašíček

Lingua::CS::Num2Words converts numbers into Czech numerals.
The ambition is to generate all legitimate variants but
current coverage is:

=over

=item 0 .. 1e12-1 for cardinals in nominative
(nula .. devět set miliard),

=item  0 .. 19999 for cardinals in genitive
(nuly .. devatenácti tisíc),

=item 0 .. 99 for ordinals in nominative and genitive
(nultý/-ého .. devadesátý devátý/-ého),

=item dates
(pátého června dva tisíce dvacet)

=back

=head2 Functions

=over
=cut

package Lingua::CS::Num2Words;

use utf8;
use strict;
use open qw(:std :utf8);
use 5.010;
use Lingua::CS::Num2Words::Cardinal::Nominative;
use Lingua::CS::Num2Words::Cardinal::Genitive;
use Lingua::CS::Num2Words::Ordinal::Nominative;
use Lingua::CS::Num2Words::Ordinal::Genitive;
use Lingua::CS::Num2Words::Date;

BEGIN {
  use Exporter ();
  use vars qw($VERSION $REVISION @ISA @EXPORT_OK);
  $VERSION    = 2.01;
  ($REVISION) = '$Revision: 0.01 $' =~ /([\d.]+)/;
  @ISA        = qw(Exporter);
  @EXPORT_OK  = qw(num2cs_cardinal num2cs_ordinal num2cs_date);
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

my %kind_case_to_package = (
  cn => 'Lingua::CS::Num2Words::Cardinal::Nominative',
  cg => 'Lingua::CS::Num2Words::Cardinal::Genitive',
  on => 'Lingua::CS::Num2Words::Ordinal::Nominative',
  og => 'Lingua::CS::Num2Words::Ordinal::Genitive',
);

sub num2cs_cardinal {
  my $num = pop;
  my %opts = @_;
  my @cases = map {substr($_, 0, 1)} split /,/, ($opts{'--case'} || 'nominativ,genitiv');
  my $kind = 'c';

  my @unfolded;
  for my $case (@cases) {
    my $package = $kind_case_to_package{$kind.$case};
    if (not $package) {
      warn "unsupported case for cardinals: $case";
      next;
    }
    say $package;
    no strict 'refs';
    my @variants = "${package}::get_variants"->($num, final => 1);

    #use Data::Dumper; print(Dumper(@variants));
    push @unfolded, unfold @variants;
  }

  my @flattened = flatten(@unfolded);
  my %flattened_dedup = map {; $_ => 1 } @flattened;
  return sort keys %flattened_dedup;
}

sub num2cs_ordinal {
  my $num = pop;
  my %opts = @_;
  my @cases = map {substr($_, 0, 1)} split /,/, ($opts{'--case'} || 'nominativ,genitiv');
  my $kind = 'o';

  my @unfolded;
  for my $case (@cases) {
    my $package = $kind_case_to_package{$kind.$case};
    if (not $package) {
      warn "unsupported case for ordinals: $case";
      next;
    }
    say $package;
    no strict 'refs';
    my @variants = "${package}::get_variants"->($num, final => 1);

    #use Data::Dumper; print(Dumper(@variants));
    push @unfolded, unfold @variants;
  }

  my @flattened = flatten(@unfolded);
  my %flattened_dedup = map {; $_ => 1 } @flattened;
  return sort keys %flattened_dedup;
}

sub num2cs_date {
  my $date_str = pop;

  my @variants = Lingua::CS::Num2Words::Date::get_variants($date_str, final => 1);
  #use Data::Dumper; print(Dumper(@variants));

  my @unfolded = unfold @variants;
  my @flattened = flatten(@unfolded);
  my %flattened_dedup = map {; $_ => 1 } @flattened;
  return sort keys %flattened_dedup;
}

1;
__END__

=back

=head1 EXPORT_OK

num2cs_cardinal

=head1 AUTHOR

Jan Oldřich Krůza C<< <sixtease@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2020 Jan Oldřich Krůza

This package is free software. You can redistribute and/or modify it under
the same terms as Perl itself.

=cut
