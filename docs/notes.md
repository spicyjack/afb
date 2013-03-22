# Infobot Factoid Browser #

Should I do, I will do, I just did

## Todo ##
- Show an alert popup box when any of the functions that are not currently
  implemented are clicked on
- Sanitize input
  - Add a function to `factoid_tool.pl` that checks the content against a
    default regex pattern, warn if any factoids don't match the pattern (i.e.
    they won't be able to be found because their corresponding search strings
    will be sanitized by the regex)
- Add a route execution timer, show execution time on the page
- Searching
  - Create a highlight `<span>` tag that is used to highlight search terms
  - Show the search term, along with a link to toggle highlighting
  - Show the number of search hits found at the bottom of the page
  - Show page navigation if there are more search terms than fit on one page
  - Redirect from the search page to the browse page if no search string is
    entered into the box when the user presses the *Search* button
  - *OR*, warn the user that they didn't enter a search string
- Factoid stats
  - Put them on their own page
  - Total number of factoids
  - Number of `is` factoids
  - Number of `are` factoids
  - Longest factoid
  - Word counts for commonly used words
- Fix the page footer (with Dancer version and link), it's scrolling up when
  it shouldn't
- Change the links at the top of the page so they change the DOM instead of
  loading a different page
- TinyURL Preview
  - Follow/decode TinyURL links
  - For image files, hide the image from the user until the user acknowledges
    NSFW-ness, or turns off safe mode

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

## Done Todos ##
20Mar2013
- Combine the `is/are` databases so they can be displayed as one set of
  factoids, and also paginated consistently
- Limit the display of factoids to only 25 per screen
- Get browsing using :start_num working
  - Create a subset of factoids to return to the user
- Colorize rows on the page so every other row is a different color
- Fix the page header, factoids are getting stuck above the header, they
  should be displaying below the header
- Get searching of factoids working


vim: filetype=markdown shiftwidth=2 tabstop=2
