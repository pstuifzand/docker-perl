# To install/use run:
#   carton install
#   carton exec perl -Ilib test.pl

use Net::Docker;
use Data::Dumper;

my $docker = Net::Docker->new;
#my $d = $docker->remove_container($ARGV[0]);
#print $d;
