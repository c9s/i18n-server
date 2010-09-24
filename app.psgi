# -*- cperl -*-
# vim:filetype=perl:et:
package main;
use Moose;
use Plack::Builder;
use Plack::Request;
use JSON::XS;
use constant debug => 1;

builder {
    # enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } "Plack::Middleware::ReverseProxy";

    mount "/" => builder {
        sub {
            my $env = shift;
            my $req = Plack::Request->new($env);
            my $params = $req->parameters;

            my $msgid  = $req->param('msgid');
            my $lang   = $req->param('lang');



            
            return [ '400', [ 'Content-Type' => 'text/plain' ], [ "Works" ] ];
        }
    };

#     mount "/" => builder {
#         enable "Static", path => qr{^/(test|pages|images|js|css)/}, root => 'public/';
#         sub {
#             my $env = shift;
#             my $req = Plack::Request->new($env);
#             my $res = $req->new_response(200);
#             $res->redirect("/pages/index.html");
#             return $res->finalize;
#         }
#     };
};
