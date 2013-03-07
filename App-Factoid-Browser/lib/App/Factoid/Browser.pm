package App::Factoid::Browser;
use Dancer;
use AnyDBM_File;
use GDBM_File;
use Fcntl qw(/^O_/);

our $VERSION = '0.1';

## setup
    my %factoids;

    # FIXME turn this into config variables

    # Apple OS X
    # my $dbm_driver = q(GDBM_File);
    #my $filename = q(/Users/brian/Downloads/Factoids/Prospero-is.dir);

    my $dbm_driver = q(AnyDBM_File);
    my $filename = q(/srv/www/purl/html/Prospero/Prospero-is);

    debug(qq(Reading in factoids from $filename));
    tie(%factoids, $dbm_driver, $filename, O_RDONLY, 0644)
        || die "Couldn't open " .  $filename . " with $dbm_driver: $!";

### original Dancer page ###
get q(/original) => sub {
    set layout => q(main);
    template q(index.orig);
};

### DEFAULT PAGE ###
get q(/) => sub {
    set layout => q(miranda);
    template q(index);
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

### /random page ###
get q(/random) => sub {
    set layout => q(miranda);
    template q(random);
};

### /random/urlpage ###
get q(/randomurl) => sub {
    set layout => q(miranda);
    template q(randomurl);
};

### /search with a :query ###
get q(/search/:query) => sub {
    set layout => q(miranda);
    template q(index);
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
