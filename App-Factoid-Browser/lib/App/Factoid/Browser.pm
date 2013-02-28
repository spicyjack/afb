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
    template 'index';
};

### DEFAULT PAGE ###
get q(/original) => sub {
    set layout => q(main);
    template    q(index.orig);
};

### /all ###
get q(/all) => sub {
    set layout => q(miranda);
    foreach my $key(sort(keys(%factoids))) {
        print qq($key => ) . $factoids{$key} . qq(\n);
    }
};

get q(/search/:query) => sub {
    set layout => q(miranda);
    my $query = param(q(query));
    debug(qq(/search/query; Query string is: $query));
    my @found_keys = grep(/$query/, keys(%factoids));
    debug(qq(/search/query; Found ) . scalar(@found_keys) . qq( keys));
    foreach my $key ( @found_keys ) {
        print qq($key => ) . $factoids{$key} . qq(\n);
    }
};

# Exiting the script should close the filehandle
# untie(%factoids) || die "untie() on " . $filename . " failed: $!";
true;
