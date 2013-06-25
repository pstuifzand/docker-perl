use lib 'lib';
use Net::Docker;
use Data::Dumper;

my $docker = Net::Docker->new;
my $d = $docker->images_viz();
print Dumper($d);

