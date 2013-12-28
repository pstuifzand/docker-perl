use Test::More;

use Net::Docker;
use Data::Dumper;

my $api = Net::Docker->new;
ok($api);

my @lines = $api->pull('busybox');
for (@lines) {
    ok(exists $_->{status});
}

my $version = $api->version;
ok($version->{GoVersion});
ok($version->{Version});

my $info = $api->info;
ok(exists $info->{Containers});
ok(exists $info->{Images});

my $inspect = $api->inspect('busybox');
is($inspect->{id}, 'e9aa60c60128cad1');

done_testing();

