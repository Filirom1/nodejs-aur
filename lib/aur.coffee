request     = require 'request'
querystring = require 'querystring'
FormData    = require 'form-data'
fs          = require 'fs'
_           = require 'underscore'
config      = require './config'

aur = module.exports =
  # Return all the information about the package
  # only name is mandatory
  info: (name, options, cb) ->
    if typeof options is 'function'
      cb = options
      options = {}
    cb or= defaultCb
    options = _.extend {}, config, options
    url = options.url.base + options.url.info + name
    request url, (err, resp, body) ->
      return cb err if err
      json = JSON.parse body
      return cb new Error(json.results) if json.type is 'error'
      cb null, json.results

  # Publish a package
  publish: (user, password, filePkg, category, cb) ->
    cb or= defaultCb
    category or= 'system'

    # The list of all available categories
    categories =
      daemons:2
      devel:3
      editors:4
      emulators:5
      games:6
      gnome:7
      i18n:8
      kde:9
      lib:10
      modules:11
      multimedia:12
      network:13
      office:14
      science:15
      system:16
      x11:17
      xfce:18
      kernels:19
    categoryId = categories[category]

    @login user, password, (err, cookie) ->
      return cb err if err
      form = new FormData()
      form.append 'pkgsubmit', '1'
      form.append 'category', categoryId + ''
      form.append 'pfile', fs.createReadStream(filePkg)
      form.getLength (err, length) ->
        return cb err if err
        form.pipe request
          method: 'POST',
          headers: form.getHeaders
            'Cookie': cookie,
            'Content-Length': length
          url: 'http://localhost:3000/test/upload'
          , (err, resp, data) ->
            return cb err if err
            return cb null, data

  # Try to login and if successful, return the cookie with the SID with the format : AURSID=xxxxxxxxxxxxxx;
  login: (user, password, cb) ->
    cb or= defaultCb
    url = config.url.base

    # Create the auth data form
    dataForm = querystring.stringify
      user: user
      passwd: password

    # Post the auth data form
    request
      url: url
      method: 'POST'
      headers:
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': dataForm.length
      body: dataForm
    , (err, resp) ->
        return cb err if err
        return cb 'Wrong login or password' if not resp.headers['set-cookie']
        setCookie = resp.headers['set-cookie']
        # Extract the SessionID (SID)
        regex = /AURSID=\w*;/
        return cb 'No SessionID' if not regex.test setCookie
        # Return the SID: format = AURSID=xxxxxxxxxxxxxx;
        cb null, regex.exec(setCookie)[0]


defaultCb = (err, results) ->
  return console.error err if err
  console.log results
