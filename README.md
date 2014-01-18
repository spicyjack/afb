# App::Factoid::Browser #

Browse and search for Infobot factoids from the comfort of your web browser.

## What's Here ##
- [Project Notes](https://github.com/spicyjack/afb/blob/master/docs/notes.md)
- Perl [Dancer](https://metacpan.org/module/Dancer) application
  - `App-Perl-Dancer/bin/app.pl`
  - Dancer web application, creates an instance of Dancer on port 3000 of
    `localhost`
- Standalone factoid tool script 
  - `App-Perl-Dancer/bin/factoid_tool.pl`
  - Can display factoid files (`factoid_file.[pag|dir]`)
- Helper scripts
  - `scripts/get_factoids.sh`
  - Downloads factoids from remote server, creates tarball for re-downloading

## Starting the app ##
Change to the `App-Factoid-Browser` directory and issue this command:

    perl bin/app.pl

You can also specify an environment with:

    perl bin/app.pl --environment production

## Licensing ##
This software is released under the terms of the *Perl Artistic License*, a
copy of which can be viewed at http://dev.perl.org/licenses/artistic.html.

vim: filetype=markdown tabstop=2 shiftwidth=2
