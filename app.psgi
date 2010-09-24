# -*- cperl -*-
# vim:filetype=perl:et:
package main;
use Moose;
use Plack::Builder;
use Plack::Request;
use JSON::XS;
use DBI;
use utf8;
use Encode;

my $database = "i18n";
my $hostname = "localhost";
my $port = 3306;
my $user = "root";
my $password = "1234";
my $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";

builder {
    # enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } "Plack::Middleware::ReverseProxy";
    mount "/" => builder {
        sub {
            my $env = shift;
            my $req = Plack::Request->new($env);

            my $params = $req->parameters;
            my $msgid  = $req->param('msgid');
            my $lang   = $req->param('lang');

            my $dbh = DBI->connect($dsn, $user, $password);
            my $sth = $dbh->prepare( "select * from messages where lang = ? and msgid = ? ; " );
            $sth->execute( $lang, $msgid );

            my $row = $sth->fetchrow_hashref() || { };
            Encode::_utf8_on($row->{msgstr});
            my $response_text = encode_json( $row );

            $sth->finish;
            $dbh->disconnect;
            return [ '400', [ 'Content-Type' => 'text/plain' ], [ $response_text ] ];
        }
    };
};
