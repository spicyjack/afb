package App::Factoid::Browser;
use Carp;
use Dancer;
use AnyDBM_File;
use GDBM_File;
use Fcntl qw(/^O_/);
use Template;

our $VERSION = '0.1';

## setup
    my (%factoids_is, %factoids_are);

    debug(qq(Current environment: ) . config->environment);
    debug(qq(Reading in factoids from: ) . config->dbm_basename);
    debug(qq(Using database driver: ) . config->dbm_driver);
    tie(%factoids_is, config->dbm_driver, config->dbm_basename . q(-is.dir),
        O_RDONLY, 0644)
        || confess q(Couldn't open ) .  config->dbm_basename . q(-is.dir with )
            . config->dbm_driver . qq(: $!);
    tie(%factoids_are, config->dbm_driver, config->dbm_basename . q(-are.dir),
        O_RDONLY, 0644)
        || confess q(Couldn't open ) .  config->dbm_basename . q(-are.dir with )
            . config->dbm_driver . qq(: $!);
    # FIXME how to combine the is/are factoids so keys don't step on each
    # other? pre-make HTML output with correct styles?

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
    template(q(browse), { factoids => \%factoids_is });
};

### /browse/:start_num ###
get q(/browse/:start_num) => sub {
    set layout => q(miranda);
    # FIXME create a subset of factoids, based on the :start_num amount
    template(q(browse), { factoids => \%factoids_is });
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
    my @found_keys = grep(/$query/, keys(%factoids_is));
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
# untie(%factoids-is) || die "untie() on " . config->dbm_basename 
#   . " failed: $!";
true;
