use Test::More;
use Net::Docker;

my $api = Net::Docker->new;

my $id = $api->create(Cmd => ['echo', 'Hello world'], Image => 'ubuntu');
like($id, qr/^[0-9a-f]+$/);

$api->start($id);

$api->streaming_logs($id, stream => 1, logs => 1, stdout => 1, sub {
    my ($log) = @_;
    is($log, 'Hello world');
});

done_testing;
