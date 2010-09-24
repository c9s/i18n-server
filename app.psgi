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


sub gather_msgtag {
    my $setid = shift;
    my $sth = $dbh->prepare(  "select * from message_tags where setid = ? " );
    $sth->execute( $setid );

}

sub gather_msgset {
    my $setid = shift;
    my $sth = $dbh->prepare(  "select * from messages where setid = ? " );
    $sth->execute( $setid );
    my $msgset = $sth->fetchall_hashref( 'id' );
    $sth->finish;
    map { Encode::_utf8_on($msgset->{$_}->{msgstr}) } keys %$msgset;

    return { 
        id => $setid,
        content => { map {
            $_->{lang} => $_->{msgstr}
            } values $msgset  }
    };
}



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
            $sth->finish;

            my $tags   = gather_msgtag($row->{setid});
            my $msgset = gather_msgset($row->{setid});


            my $result = {
                id => $row->{setid},
                tags => $tags,
                content => $msgset,
            };

            Encode::_utf8_on($row->{msgstr});
            my $response_text = encode_json( $row );

            $dbh->disconnect;
            return [ '400', [ 'Content-Type' => 'text/plain' ], [ $response_text ] ];
        }
    };
};
