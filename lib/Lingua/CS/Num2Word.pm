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

use strict;
use utf8;
use open qw(:std :utf8);
use 5.010;
use Lingua::CS::Num2Word::Cardinal::Nominative;

BEGIN {
  use Exporter ();
  use vars qw($VERSION $REVISION @ISA @EXPORT_OK);
  $VERSION    = 2.01;
  ($REVISION) = '$Revision: 0.01 $' =~ /([\d.]+)/;
  @ISA        = qw(Exporter);
  @EXPORT_OK  = qw(&num2cs_cardinal);
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
  my @variants = Lingua::CS::Num2Word::Cardinal::Nominative::get_variants($num, final => 1);
  #use Data::Dumper; print(Dumper(@variants));
  my @unfolded = unfold @variants;
  return flatten(@unfolded);
}

1;
__END__

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
