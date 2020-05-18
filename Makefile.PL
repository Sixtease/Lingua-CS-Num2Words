use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'              => 'Lingua::CS::Num2Words',
    'VERSION_FROM'      => 'lib/Lingua/CS/Num2Words.pm',
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (AUTHOR     => 'Roman Vasicek <rv@petamem.com>') : ())
);
