#!/usr/bin/perl -w

# Copyright (c) 2012 by Brian Manning <devspam at xaoc dot org>
# For help with script errors and feature requests,
# please contact the author on IRC;
# irc.freenode.net #kernel-panic, nick: spicyjack

=head1 NAME

B<factoid_tool.pl> - Browse, maintain and dump C<Infobot> factoid files.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 perl factoid_tool.pl [OPTIONS]

 Script options:
 -v|--verbose       Verbose script execution
 -h|--help          Shows this help text

 Other script options:
 -f|--file          Path to factoid file; may be used multiple times
 -d|--dump          Dump the factoid file(s) as key/value pairs to STDOUT
 -l|--list          Pretty-print key/value pairs to STDOUT
 -k|--keys          List factoid keys
 -s|--values        List factoid values

 Example usage:

 # list factoids in /path/to/factoid-is.[dir|pag]
 factoid_tool.pl --file /path/to/factoid-is --list

You can view the full C<POD> documentation of this file by calling C<perldoc
factoid_tool.pl>.

=head1 DESCRIPTION

B<factoid_tool.pl> - Browse, maintain and dump C<Infobot> factoid files.

=head1 OBJECTS

=head2 FactoidTool::Config

An object used for storing configuration data.

=head3 Object Methods

=cut

######################
# FactoidTool::Config #
######################
package FactoidTool::Config;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);

=over

=item new( )

Creates the L<FactoidTool::Config> object, and parses out options using
L<Getopt::Long>.

=cut

sub new {
    my $class = shift;

    my $self = bless ({}, $class);

    # script arguments
    my %args;

    # parse the command line arguments (if any)
    my $parser = Getopt::Long::Parser->new();

    # pass in a reference to the args hash as the first argument
    $parser->getoptions(
        \%args,
        # script options
        q(verbose|v+),
        q(help|h),
        # other options
        q(file|f=s@),
        q(dump|d),
        q(list|l),
        q(keys|k),
        q(values|s),
    ); # $parser->getoptions

    # assign the args hash to this object so it can be reused later on
    $self->{_args} = \%args;

    # dump and bail if we get called with --help
    if ( $self->get(q(help)) ) { pod2usage(-exitstatus => 1); }

    # return this object to the caller
    return $self;
} # sub new

=item get($key)

Returns the scalar value of the key passed in as C<key>, or C<undef> if the
key does not exist in the L<FactoidTool::Config> object.

=cut

sub get {
    my $self = shift;
    my $key = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    if ( exists $args{$key} ) { return $args{$key}; }
    return undef;
} # sub get

=item set( key => $value )

Sets in the L<FactoidTool::Config> object the key/value pair passed in as
arguments.  Returns the old value if the key already existed in the
L<FactoidTool::Config> object, or C<undef> otherwise.

=cut

sub set {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    # turn the args reference back into a hash with a copy
    my %args = %{$self->{_args}};

    if ( exists $args{$key} ) {
        my $oldvalue = $args{$key};
        $args{$key} = $value;
        $self->{_args} = \%args;
        return $oldvalue;
    } else {
        $args{$key} = $value;
        $self->{_args} = \%args;
    } # if ( exists $args{$key} )
    return undef;
} # sub get

=item get_args( )

Returns a hash containing the parsed script arguments.

=cut

sub get_args {
    my $self = shift;
    # hash-ify the return arguments
    return %{$self->{_args}};
} # get_args

=back

=head2 FactoidTool::Logger

A simple logger module, for logging script output and errors.

=head3 Object Methods

=cut

######################
# FactoidTool::Logger #
######################
package FactoidTool::Logger;
use strict;
use warnings;
use POSIX qw(strftime);
use IO::File;
use IO::Handle;

=over

=item new($config)

Creates the L<FactoidTool::Logger> object, and sets up various filehandles
needed to log to files or C<STDOUT>.  Requires a L<FactoidTool::Config> object
as the argument, so that options having to deal with logging can be
parsed/acted upon.  Returns the logger object to the caller.

=cut

sub new {
    my $class = shift;
    my $config = shift;

    my $logfd;
    if ( defined $config->get(q(logfile)) ) {
        # append to the existing logfile, if any
        $logfd = IO::File->new(q( >> ) . $config->get(q(logfile)));
        die q( ERR: Can't open logfile ) . $config->get(q(logfile)) . qq(: $!)
            unless ( defined $logfd );
        # apply UTF-8-ness to the filehandle
        $logfd->binmode(qq|:encoding(utf8)|);
    } else {
        # set :utf8 on STDOUT before wrapping it in IO::Handle
        binmode(STDOUT, qq|:encoding(utf8)|);
        $logfd = IO::Handle->new_from_fd(fileno(STDOUT), q(w));
        die qq( ERR: could not wrap STDOUT in IO::Handle object: $!)
            unless ( defined $logfd );
    } # if ( exists $args{logfile} )
    $logfd->autoflush(1);

    my $self = bless ({
        _OUTFH => $logfd,
    }, $class);

    # return this object to the caller
    return $self;
} # sub new

=item log($message)

Log C<$message> to the logfile, or I<STDOUT> if the B<--logfile> option was
not used.

=cut

sub log {
    my $self = shift;
    my $msg = shift;

    my $FH = $self->{_OUTFH};
    print $FH $msg . qq(\n);
} # sub log

=item timelog($message)

Log C<$message> with a timestamp to the logfile, or I<STDOUT> if the
B<--logfile> option was not used.

=cut

sub timelog {
    my $self = shift;
    my $msg = shift;
    my $timestamp = POSIX::strftime( q(%c), localtime() );

    my $FH = $self->{_OUTFH};
    print $FH $timestamp . q(: ) . $msg . qq(\n);
} # sub timelog

=back

=head2 FactoidTool::File

An object that represents the file that is to be streamed to the
Icecast/Shoutcast server.  This is a helper object for the file that helps out
different functions related to file metadata and logging output.  Returns
C<undef> if the file doesn't exist on the filesystem or can't be read.

=head3 Object Methods

=cut

#####################
# FactoidTool::File #
#####################
package FactoidTool::File;
use strict;
use warnings;

=over

=item new(filename => $file, logger => $logger, config => $config)

Creates an object that wraps the factoid file.

=cut

sub new {
    my $class = shift;
    my %args = @_;

    my ($filename, $logger, $config);
    die qq( ERR: Missing factoid filename as 'filename =>')
        unless ( exists $args{filename} );
    $filename = $args{filename};

    die qq( ERR: FactoidTool::Logger object required as 'logger =>')
        unless ( exists $args{logger} );
    $logger = $args{logger};

    die qq( ERR: FactoidTool::Logger object required as 'logger =>')
        unless ( exists $args{config} );
    $config = $args{config};

    my $self = bless ({
        # save the config and logger objects so that this object's methods can
        # use them
        _logger => $logger,
        _config => $config,
        _filename => $filename,
        _db => undef,
    }, $class);

    # some tests of the actual file on the filesystem
    # does it exist?
    unless ( -e $self->get_filename() ) {
        $logger->timelog( qq(WARN: Missing file on filesystem!) );
        $logger->log(qq(- ) . $self->get_display_name() );
        # return an undefined object so that callers know something's wrong
        undef $self;
    } # unless ( -e $self->get_filename() )

    # previous step may have set $self to undef
    if ( defined $self ) {
        # can we read the file?
        unless ( -r $self->get_filename() ) {
            $logger->timelog( qq(WARN: Can't read file on filesystem!) );
            $logger->log(qq(- ) . $self->get_display_name() );
            # return an undefined object so that callers know something's wrong
            undef $self;
        } # unless ( -r $self->get_filename() )
    } # if ( defined $self )

#    my $db = DBM::Deep->new(
#        file => $self->get_filename(),
#        type => TYPE_HASH,
#    );
#    $self->{_db} = $db;
    return $self
} # sub new

=back

=cut

################
# package main #
################
package main;
use strict;
use warnings;
use AnyDBM_File;
use Fcntl qw(/^O_/);

    # create a logger object
    my $config = FactoidTool::Config->new();

    # create a logger object, and prime the logfile for this session
    my $logger = FactoidTool::Logger->new($config);
    $logger->timelog(qq(INFO: Starting factoid_tool.pl, version $VERSION));
    $logger->timelog(qq(INFO: my PID is $$));

    my %factoids;

    # tie(%variable, $module_name, $db_filename, $mask)
    foreach my $filename ( @{$config->get(q(file))} ) {
        tie(%factoids, q(AnyDBM_File), $filename, O_RDONLY, 0644)
            || die "Couldn't open " .  $filename . " with AnyDBM_File: $!";

        foreach my $key(sort(keys(%factoids))) {
            print qq($key => ) . $factoids{$key} . qq(\n);
        }

        untie(%factoids) || die "untie() on " .  $config->get(q(file)) 
            . " failed: $!";
    }
exit 0;

=head1 AUTHOR

Brian Manning, C<< <devspam at xaoc dot org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<< <irc://irc.freenode.com/#kernel-panic spicyjack> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

    perldoc factoid_tool.pl

=head1 COPYRIGHT & LICENSE

Copyright (c) 2012-2013 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set sw=4 ts=4
