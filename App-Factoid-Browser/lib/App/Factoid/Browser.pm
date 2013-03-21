package App::Factoid::Browser;
use Carp;
use Dancer;
use AnyDBM_File;
use GDBM_File;
use Fcntl qw(/^O_/);
use Template;

our $VERSION = '0.3';

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
    my %args = @_;
    die(q|Missing Factoid array (factoids)|)
        unless(defined $args{factoids});
    my $start_num = $args{start_num};
    my $lines = $args{lines};
    my @factoids = sort(@{$args{factoids}});
    # if start_num was not passed in, or if it's not a number
    if ( ! defined $start_num || $start_num !~ /\d+/ ) {
        $start_num = 0;
    }
    # if start_num is larger than the number of factoids, reset to 0
    if ( $start_num > scalar(@factoids) ) {
        $start_num = 0;
    }
    if ( ! defined $lines || $lines !~ /\d+/ ) {
        $lines = 24;
    }
    # if start_num is larger than the number of factoids, reset to 0
    if ( $lines > scalar(@factoids) ) {
        $lines = scalar(@factoids);
    }
    debug(" get_browse_data: starting at $start_num");
    my @spliced_factoids;
    my $flag = 0;
    my $end_num;
    # check to see if we have enough factoids for a screenful
    if ( $start_num + $lines < scalar(@factoids) ) {
        $end_num = $start_num + $lines;
    } else {
        $end_num = scalar(@factoids) - 1;
    }
    debug(" get_browse_data: ending at $end_num");
    for (my $i = $start_num; $i <= $end_num; $i++) {
        my $div;
        if ( $flag ) {
            $div = q(<div class="line">);
            $flag = 0;
        } else {
            $div = q(<div class="altline">);
            $flag = 1;
        }
        push(@spliced_factoids, $div . q(<span class="line_num">)
            . sprintf("%6u", $i + 1) . q(</span>) . $factoids[$i]
            . q(</div>));
    }
    #@spliced_factoids = splice(@factoids_copy, $start_num, 25);
    debug(q( get_browse_data: returning ) . scalar(@spliced_factoids)
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
    template q(search);
};

### /browse ###
get q(/browse) => sub {
    my $data_ref = get_browse_data(
        factoids => \@combined_factoids,
    );
    template(q(browse), {factoids => $data_ref });
};

### /browse/:start_num ###
get q(/browse/:start_num) => sub {
    my $data_ref = get_browse_data( 
        start_num   => param(q(start_num)),
        factoids    => \@combined_factoids,
    );
    template(q(browse), {factoids => $data_ref });
};
### /browse/:start_num ###
get q(/browse/:start_num/:lines) => sub {
    my $data_ref = get_browse_data(
        start_num   => param(q(start_num)),
        lines       => param(q(lines)),
        factoids    => \@combined_factoids,
    );
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
    my $query = param(q(query));
    debug(qq(/search/query; Query string is: $query));
    my @found_factoids = grep(/$query/, @combined_factoids);
    debug(qq(/search/query; Found ) . scalar(@found_factoids) . qq( factoids));
    my $data_ref = get_browse_data( 
        factoids => \@found_factoids,
    );
    template(q(search), {
        factoids        => $data_ref,
        search_string   => \$query,
    });
};

### /search with a :query ###
get q(/search/:query/:start_num) => sub {
    my $query = param(q(query));
    debug(qq(/search/query; Query string is: $query));
    my @found_factoids = grep(/$query/, @combined_factoids);
    debug(qq(/search/query; Found ) . scalar(@found_factoids) . qq( keys));
    my $data_ref = get_browse_data( 
        start_num   => param(q(start_num)),
        factoids    => \@found_factoids,
    );
    template(q(search), {
        factoids        => $data_ref,
        search_string   => \$query,
    });
};
=pod

    print qq(HTTP/1.1 200 OK\nContent-type: text/html\n\n);
    print qq(<html>\n<body>\n);
    foreach my $key ( @found_keys ) {
        print qq(<div>$key => ) . $factoids{$key} . qq(</div>\n);
    }
    print qq(</body>\n</html>\n);

=cut


# Exiting the script should close the filehandle
# untie(%factoids-is) || die "untie() on " . config->dbm_basename 
#   . " failed: $!";
true;
