package App::Factoid::Browser;
use Dancer;
use AnyDBM_File;
use Fcntl qw(/^O_/);

our $VERSION = '0.1';

## setup
    my %factoids;
    my $filename = q(/srv/www/purl/html/Prospero/Prospero-is);
    debug(qq(Reading in factoids from $filename));
    tie(%factoids, q(AnyDBM_File), $filename, O_RDONLY, 0644)
        || die "Couldn't open " .  $filename . " with AnyDBM_File: $!";

### DEFAULT PAGE ###
get q(/) => sub {
    set layout => q(miranda);
    template q(index);
};

### original Dancer page ###
get q(/original) => sub {
    set layout => q(main);
    template q(index.orig);
};

### /browse ###
get q(/browse) => sub {
    set layout => q(miranda);
    template q(browse);

=pod

    print qq(HTTP/1.1 200 OK\nContent-type: text/html\n\n);
    print qq(<html>\n<body>\n);
    foreach my $key(sort(keys(%factoids))) {
        print qq(<div>$key => ) . $factoids{$key} . qq(</div>\n);
    }
    print qq(</body>\n</html>\n);

=cut

};

### /search page ###
get q(/search/:query) => sub {
    set layout => q(miranda);
    template q(search);
};

### /search with a :query ###
get q(/search/:query) => sub {
    set layout => q(miranda);
    template q(search);
    my $query = param(q(query));
    debug(qq(/search/query; Query string is: $query));
    my @found_keys = grep(/$query/, keys(%factoids));
    debug(qq(/search/query; Found ) . scalar(@found_keys) . qq( keys));

=pod

    print qq(HTTP/1.1 200 OK\nContent-type: text/html\n\n);
    print qq(<html>\n<body>\n);
    foreach my $key ( @found_keys ) {
        print qq(<div>$key => ) . $factoids{$key} . qq(</div>\n);
    }
    print qq(</body>\n</html>\n);

=cut

};

# Exiting the script should close the filehandle
# untie(%factoids) || die "untie() on " . $filename . " failed: $!";
true;
