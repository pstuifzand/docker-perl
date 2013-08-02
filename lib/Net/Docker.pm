package Net::Docker;
use strict;
our $VERSION = '0.001000';

use Moo;
use JSON;
use URI;
use URI::QueryParam;
use LWP::UserAgent;
use Carp;

has address => (is => 'ro', default => 'http://127.0.0.1:4243');
has ua      => (is => 'lazy');

sub _build_ua {
    my $ua = LWP::UserAgent->new;
    return $ua;
}

sub _uri {
    my ($self, $rel, %options) = @_;
    my $uri = URI->new($self->address . $rel);
    $uri->query_form(%options);
    return $uri;
}

sub _parse {
    my ($self, $uri, %options) = @_;
    my $res = $self->ua->get($self->_uri($uri, %options));
    if ($res->content_type eq 'application/json') {
        return decode_json($res->decoded_content);
    }
    my $message = $res->decoded_content;
    $message =~ s/\r?\n$//;
    croak $message;
}

sub ps {
    my ($self, %options) = @_;
    return $self->_parse('/containers/ps', %options);
}

sub images {
    my ($self, %options) = @_;
    return $self->_parse('/images/json', %options);
}

sub images_viz {
    my ($self, %options) = @_;
    return $self->_parse('/images/viz', %options);
}

sub search {
    my ($self, %options) = @_;
    return $self->_parse('/images/search', %options);
}

sub history {
    my ($self, $image, %options) = @_;
    return $self->_parse('/images/'.$image.'/history', %options);
}

sub inspect {
    my ($self, $image, %options) = @_;
    return $self->_parse('/images/'.$image.'/json', %options);
}

sub version {
    my ($self, %options) = @_;
    return $self->_parse('/version', %options);
}

sub info {
    my ($self, %options) = @_;
    return $self->_parse('/info', %options);
}

sub inspect_container {
    my ($self, $name, %options) = @_;
    return $self->_parse('/containers/'.$name.'/json', %options);
}

sub export {
    my ($self, $name, %options) = @_;
    return $self->_parse('/containers/'.$name.'/export', %options);
}

sub diff {
    my ($self, $name, %options) = @_;
    return $self->_parse('/containers/'.$name.'/changes', %options);
}

sub remove_image {
    my ($self, @names) = @_;
    for my $image (@names) {
        $self->ua->request(HTTP::Request->new('DELETE', $self->_uri('/images/'.$image)));
    }
    return;
}

sub remove_container {
    my ($self, @names) = @_;
    for my $container (@names) {
        $self->ua->request(HTTP::Request->new('DELETE', $self->_uri('/containers/'.$container)));
    }
    return;
}

sub start {
    my ($self, $name, %options) = @_;
    $self->ua->post($self->_uri('/containers/'.$name.'/start'));
    return;
}

sub stop {
    my ($self, $name, %options) = @_;
    $self->ua->post($self->_uri('/containers/'.$name.'/stop'));
    return;
}

sub logs {
    my ($self, $container) = @_;
    my %params = (
        logs => 1,
        stdout => 1,
        stderr => 1,
    );
    my $url = $self->_uri('/containers/'.$container.'/attach');
    my $res = $self->ua->post($url, \%params);
    return $res->content;
}

1;

=head1 NAME

Net::Docker - Interface to the Docker API

=head1 AUTHOR

Peter Stuifzand E<lt>peter@stuifzand.euE<gt>

=head1 COPYRIGHT

Copyright 2013 - Peter Stuifzand

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
