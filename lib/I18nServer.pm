package I18nServer;
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};


get '/texts/:language/:content' => sub {
    my $self = shift;

    my $language = params->{language};
    my $content = params->{content};

    my $text = {
        tags => [],
        content => {
            'en_US' => "XXX",
            'zh_TW' => "XXX"
        }
    };

    return to_json($text);
};

require YAML;

post '/texts' => sub {
    my $text = from_json(request->body);

    # $text
    return to_json($text);
};


true;
