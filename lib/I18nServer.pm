package I18nServer;
use Dancer ':syntax';
use MongoDB;
use Hash::Merge qw(merge);

our $VERSION = '0.1';

{
    my $conn = MongoDB::Connection->new( host => 'localhost' , post => 27017 );
    my $db = $conn->i18nServer;
    my $collection = $db->messages;

    sub db {
        return $db
    }

    sub Message {
        return $db->messages;
    }
}

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

post '/texts' => sub {
    my $text = from_json(request->body);

    my $m = Message->find_one({ 'content.en_US' => $text->{content}{en_US} });

    if ($m) {
        delete $text->{_id};

        my $t2 = merge($text, $m);

        print YAML::Dump($t2);

        Message->update(
            { _id => $m->{_id} },
            $t2
        );

        return to_json({ id => $m->{_id}->value });
    }
    else {
        # $text
        my $id = Message->insert($text);

        return to_json({ id => $id->value });
    }
};


true;
