request     = require 'request'
querystring = require 'querystring'
FormData    = require 'form-data'
fs          = require 'fs'
_           = require 'underscore'
config      = require './config'
cheerio     = require "cheerio"

request = request.defaults proxy: process.env['https_proxy'], jar: false

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
    request url:url, (err, resp, body) ->
      return cb err if err
      json = JSON.parse body
      return cb new Error(json.results) if json.type is 'error'
      cb null, json.results

  # Publish a package
  publish: (user, password, filePkg, category, options, cb) ->
    if typeof options is 'function'
      cb = options
      options = {}
    cb or= defaultCb
    if typeof category is 'object'
      options = category
      category = null
    category or= 'system'
    options = _.extend {}, config, options

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

    @login user, password, options, (err, cookie) ->
      return cb err if err
      form = new FormData()
      form.append 'pkgsubmit', '1'
      form.append 'token', cookie.replace('AURSID=', '')
      form.append 'category', categoryId + ''
      form.append 'pfile', fs.createReadStream(filePkg)
      form.getLength (err, length) ->
        return cb err if err
        form.pipe request
          method: 'POST',
          headers: form.getHeaders
            'Cookie': cookie
            'Content-Length': length
          url: options.url.base + options.url.post
          , (err, resp, data) ->
            return cb err if err
            $ = cheerio.load data
            return cb new Error $(".pkgoutput").text() if $('.pkgoutput').text()
            return cb null, data

  # Try to login and if successful, return the cookie with the SID with the format : AURSID=xxxxxxxxxxxxxx;
  login: (user, password, options, cb) ->
    if typeof options is 'function'
      cb = options
      options = {}
    cb or= defaultCb
    options = _.extend {}, config, options
    url = options.url.base

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
        return cb new Error('Wrong login or password') if not resp.headers['set-cookie']
        setCookie = resp.headers['set-cookie']
        # Extract the SessionID (SID)
        regex = /AURSID=\w*/
        return cb new Error('No SessionID') if not regex.test setCookie
        # Return the SID: format = AURSID=xxxxxxxxxxxxxx
        sid=regex.exec(setCookie)[0];
        cb null, sid


defaultCb = (err, results) ->
  return console.error err if err
  console.log results
