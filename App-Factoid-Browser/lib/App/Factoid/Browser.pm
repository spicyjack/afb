package App::Factoid::Browser;
use Carp;
use Dancer;
use AnyDBM_File;
use GDBM_File;
use Fcntl qw(/^O_/);
use Template;

our $VERSION = '0.2';

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
    # pre-make lists of factoids with correct CSS styles
    my @combined_factoids;
    foreach my $is ( keys(%factoids_is) ) {
        push(@combined_factoids, $is . q( <span class="is">is</span> )
            . $factoids_is{$is});
    }
    foreach my $are ( keys(%factoids_are) ) {
        push(@combined_factoids, $are . q( <span class="are">are</span> )
            . $factoids_are{$are});
    }
    debug(q(Total combined factoids: ) . scalar(@combined_factoids));

### set up a list of factoids for when browsing ###
sub get_browse_data {
    my $start_num = shift;
    if ( ! defined $start_num || $start_num !~ /\d+/ ) {
        $start_num = 0;
    }
    debug("get_browse_data: starting at start_num $start_num");
    my @factoids_copy = sort(@combined_factoids);
    my @spliced_factoids;
    my $flag = 0;
    for (my $i = $start_num; $i <= ($start_num + 25); $i++) {
        my $div;
        if ( $flag ) {
            $div = q(<div class="line">);
            $flag = 0;
        } else {
            $div = q(<div class="altline">);
            $flag = 1;
        }
        push(@spliced_factoids, $div . q(<span class="line_num">)
            . sprintf("%6u", $i) . q(</span>) . $factoids_copy[$i]
            . q(</div>));
    }
    #@spliced_factoids = splice(@factoids_copy, $start_num, 25);
    debug(q(get_browse_data: returning ) . scalar(@spliced_factoids)
        . q( factoids, starting at factoid #) . $start_num);
    return \@spliced_factoids;
}

### original Dancer page ###
get q(/original) => sub {
    set layout => q(main);
    template q(index.orig);
};

### DEFAULT PAGE ###
get q(/) => sub {
    template q(index);
};

### /browse ###
get q(/browse) => sub {
    my $data_ref = get_browse_data();
    template(q(browse), {factoids => $data_ref });
};

### /browse/:start_num ###
get q(/browse/:start_num) => sub {
    my $data_ref = get_browse_data( param(q(start_num)) );
    template(q(browse), {factoids => $data_ref });
};

### /random page ###
get q(/random) => sub {
    template q(random);
};

### /random/urlpage ###
get q(/randomurl) => sub {
    template q(randomurl);
};

### /search with a :query ###
get q(/search/:query) => sub {
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
