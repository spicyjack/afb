# Infobot Factoid Browser #

Should I do, I will do, I just did

## Todo ##
- Sanitize input

## API List ##
- `/browse` - Browse factoids
- `/search/<query string>` - Search for <query string> in keys/values
- `/random` - Random factoid
- `/random/url` - Random factoid that contains a URL of some sort

## Feature Ideas ##
- Random URL; redirects to or opens in a new window a URL found in the
  database
- look-ahead searching of factoid keys; cache search words by first letter,
  and return a full set of cached words as soon as the first letter is typed
- AJAX-ian search interface
- IRC bot that responds to requests for searches and random URLs

## Logo Ideas ##
- http://www.chrisbeetles.com/sites/default/files/stock-images/MIRANDA-THE-TEMPESTTHE-CHARACTER-OF-MIRANDA-RESOLVES-ITSELF-INTO-THE-VERY-ELEMENTS-OF-WOMANHOOD-1-T0182.jpg
- http://en.wikipedia.org/wiki/Miranda_(moon)

vim: filetype=markdown shiftwidth=2 tabstop=2
