use utf8;
use Test::More;

use Lingua::CS::Num2Words qw(num2cs_cardinal);

BEGIN { plan tests => 3 }

is_deeply(
  [num2cs_cardinal(2)],
  [qw(dva dvou dvě)],
);

is(num2cs_cardinal(case => 'n', gender => 'f', 2), 'dvě');

is_deeply(
  [num2cs_cardinal(462185001925)],
  [
    'čtyři sta dvaašedesát miliard sto osmdesát pět milionů devatenáct set dvacet pět',
    'čtyři sta dvaašedesát miliard sto osmdesát pět milionů devatenáct set pětadvacet',
    'čtyři sta dvaašedesát miliard sto osmdesát pět milionů jeden tisíc devět set dvacet pět',
    'čtyři sta dvaašedesát miliard sto osmdesát pět milionů jeden tisíc devět set pětadvacet',
    'čtyři sta dvaašedesát miliard sto osmdesát pět milionů tisíc devět set dvacet pět',
    'čtyři sta dvaašedesát miliard sto osmdesát pět milionů tisíc devět set pětadvacet',
    'čtyři sta dvaašedesát miliard sto pětaosmdesát milionů devatenáct set dvacet pět',
    'čtyři sta dvaašedesát miliard sto pětaosmdesát milionů devatenáct set pětadvacet',
    'čtyři sta dvaašedesát miliard sto pětaosmdesát milionů jeden tisíc devět set dvacet pět',
    'čtyři sta dvaašedesát miliard sto pětaosmdesát milionů jeden tisíc devět set pětadvacet',
    'čtyři sta dvaašedesát miliard sto pětaosmdesát milionů tisíc devět set dvacet pět',
    'čtyři sta dvaašedesát miliard sto pětaosmdesát milionů tisíc devět set pětadvacet',
    'čtyři sta šedesát dva miliard sto osmdesát pět milionů devatenáct set dvacet pět',
    'čtyři sta šedesát dva miliard sto osmdesát pět milionů devatenáct set pětadvacet',
    'čtyři sta šedesát dva miliard sto osmdesát pět milionů jeden tisíc devět set dvacet pět',
    'čtyři sta šedesát dva miliard sto osmdesát pět milionů jeden tisíc devět set pětadvacet',
    'čtyři sta šedesát dva miliard sto osmdesát pět milionů tisíc devět set dvacet pět',
    'čtyři sta šedesát dva miliard sto osmdesát pět milionů tisíc devět set pětadvacet',
    'čtyři sta šedesát dva miliard sto pětaosmdesát milionů devatenáct set dvacet pět',
    'čtyři sta šedesát dva miliard sto pětaosmdesát milionů devatenáct set pětadvacet',
    'čtyři sta šedesát dva miliard sto pětaosmdesát milionů jeden tisíc devět set dvacet pět',
    'čtyři sta šedesát dva miliard sto pětaosmdesát milionů jeden tisíc devět set pětadvacet',
    'čtyři sta šedesát dva miliard sto pětaosmdesát milionů tisíc devět set dvacet pět',
    'čtyři sta šedesát dva miliard sto pětaosmdesát milionů tisíc devět set pětadvacet',
    'čtyři sta šedesát dvě miliardy sto osmdesát pět milionů devatenáct set dvacet pět',
    'čtyři sta šedesát dvě miliardy sto osmdesát pět milionů devatenáct set pětadvacet',
    'čtyři sta šedesát dvě miliardy sto osmdesát pět milionů jeden tisíc devět set dvacet pět',
    'čtyři sta šedesát dvě miliardy sto osmdesát pět milionů jeden tisíc devět set pětadvacet',
    'čtyři sta šedesát dvě miliardy sto osmdesát pět milionů tisíc devět set dvacet pět',
    'čtyři sta šedesát dvě miliardy sto osmdesát pět milionů tisíc devět set pětadvacet',
    'čtyři sta šedesát dvě miliardy sto pětaosmdesát milionů devatenáct set dvacet pět',
    'čtyři sta šedesát dvě miliardy sto pětaosmdesát milionů devatenáct set pětadvacet',
    'čtyři sta šedesát dvě miliardy sto pětaosmdesát milionů jeden tisíc devět set dvacet pět',
    'čtyři sta šedesát dvě miliardy sto pětaosmdesát milionů jeden tisíc devět set pětadvacet',
    'čtyři sta šedesát dvě miliardy sto pětaosmdesát milionů tisíc devět set dvacet pět',
    'čtyři sta šedesát dvě miliardy sto pětaosmdesát milionů tisíc devět set pětadvacet',
  ],
);
