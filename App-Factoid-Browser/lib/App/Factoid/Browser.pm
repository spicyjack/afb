package App::Factoid::Browser;
use Dancer;
use AnyDBM_File;
use GDBM_File;
use Fcntl qw(/^O_/);
use Template;

our $VERSION = '0.1';

## setup
    my %factoids;

    my ($dbm_driver, $dbm_filename);
    debug(qq(Current environment: ) . config->environment);
    debug(qq(Reading in factoids from: ) . config->dbm_filename);
    debug(qq(Using database driver: ) . config->dbm_driver);
    tie(%factoids, config->dbm_driver, config->dbm_filename, O_RDONLY, 0644)
        || die q(Couldn't open ) .  config->dbm_filename . q( with )
            . config->dbm_driver . qq(: $!);

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
    template(q(browse), { factoids => \%factoids });

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
