package Net::Docker;
use strict;
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

sub version {
    my ($self, %options) = @_;
    return $self->_parse('/version', %options);
}

sub info {
    my ($self, %options) = @_;
    return $self->_parse('/info', %options);
}

sub container_export {
    my ($self, $name, %options) = @_;
    return $self->_parse('/containers/'.$name.'/export', %options);
}

sub container_changes {
    my ($self, $name, %options) = @_;
    return $self->_parse('/containers/'.$name.'/changes', %options);
}

sub container_json {
    my ($self, $name, %options) = @_;
    return $self->_parse('/containers/'.$name.'/json', %options);
}

1;

