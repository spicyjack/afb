# Infobot Factoid Browser #

Should I do, I will do, I just did

## Todo ##
- Sanitize input
  - Add a function to `factoid_tool.pl` that checks the content against a
    default regex pattern, warn if any factoids don't match the pattern (i.e.
    they won't be able to be found because their corresponding search strings
    will be sanitized by the regex)

## API List ##
- `/browse` - Browse factoids
- `/search/<query string>` - Search for <query string> in keys/values
- `/random` - Random factoid
- `/random/url` - Random factoid that contains a URL of some sort

## Feature Ideas ##
- Obfuscate e-mail addresses so they don't get harvested
- Random URL; redirects to or opens in a new window a URL found in the
  database
  - Verify URLs offline, don't link to invalid URLs
- look-ahead searching of factoid keys; cache search words by first letter,
  and return a full set of cached words as soon as the first letter is typed
- AJAX-ian search interface
- IRC bot that responds to requests for searches and random URLs
- "Lock" - lock definitions, and replace them via interaction via IRC when
  they get tampered with

## Logo Ideas ##
- http://www.chrisbeetles.com/sites/default/files/stock-images/MIRANDA-THE-TEMPESTTHE-CHARACTER-OF-MIRANDA-RESOLVES-ITSELF-INTO-THE-VERY-ELEMENTS-OF-WOMANHOOD-1-T0182.jpg
- http://en.wikipedia.org/wiki/Miranda_(moon)

## Bootstrap Links ##
- http://twitter.github.com/bootstrap/scaffolding.html
- http://twitter.github.com/bootstrap/components.html
- http://twitter.github.com/bootstrap/javascript.html
- http://twitter.github.com/bootstrap/customize.html
vim: filetype=markdown shiftwidth=2 tabstop=2
