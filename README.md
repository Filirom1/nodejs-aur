ArchLinux AUR helper
====================

A CLI to call ArchLinux AUR services.

### AUR info

Usage: ./bin/aur-info packageName

Options:

  -s, --selector  [default: ""]

Exemple:

    $ ./bin/aur-info nodejs-npm
    { Maintainer: 'neokuno',
      ID: '43626',
      Name: 'nodejs-npm',
      Version: '1.0.104-1',
      CategoryID: '3',
      Description: 'a package manager for node',
      URL: 'http://npmjs.org/',
      License: 'MIT',
      NumVotes: '151',
      OutOfDate: '0',
      FirstSubmitted: '1289874396',
      LastModified: '1320540926',
      URLPath: '/packages/no/nodejs-npm/nodejs-npm.tar.gz' }


You can also use selectors in your query:

    ./bin/aur-info nodejs-npm --selector Version
    1.0.104-1


### AUR publish

Usage: node ./bin/aur-publish

Options:

  -f, --file      [required]

  -c, --category  [required]  [default: "system"]

  -u, --user      [default: ""]

  -p, --password  [default: ""]


Exemple:

./bin/aur-publish -f nodejs-express-2.5.0-1.src.tar.gz -c devel -u USERNALE -p PASSWORD

Valid categories are :

 * daemons
 * devel
 * editors
 * emulators
 * games
 * gnome
 * i18n
 * kde
 * lib
 * modules
 * multimedia
 * network
 * office
 * science
 * system
 * x11
 * xfce
 * kernels
