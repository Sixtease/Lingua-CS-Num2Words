package Lingua::CS::Num2Words::Cardinal::Accusative;

use utf8;
use strict;
use 5.010;
use Lingua::CS::Num2Words::Cardinal::Nominative;

our %token1_f = (
  %Lingua::CS::Num2Words::Cardinal::Nominative::token1_f,
  qw( 0 nulu 1 jednu )
);

1;
