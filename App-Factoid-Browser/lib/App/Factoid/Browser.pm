package App::Factoid::Browser;
use Dancer;
use AnyDBM_File;
use Fcntl qw(/^O_/);

our $VERSION = '0.1';

get '/' => sub {
    #template 'index';
    my %factoids;
    my $filename = q(/srv/www/purl/html/Prospero/Prospero-is);
    tie(%factoids, q(AnyDBM_File), $filename, O_RDONLY, 0644)
        || die "Couldn't open " .  $filename . " with AnyDBM_File: $!";

    foreach my $key(sort(keys(%factoids))) {
        print qq($key => ) . $factoids{$key} . qq(\n);
    }

    untie(%factoids) || die "untie() on " . $filename . " failed: $!";

};

true;
