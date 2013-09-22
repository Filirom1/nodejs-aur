vows    = require 'vows'
assert  = require 'assert'
express = require 'express'
aur     = require '../lib/aur'

app     = express.createServer()
app.use express.bodyParser()

module.exports.suite = vows
  .describe('Test nodejs-aur')
  .addBatch
    'Given a fake AUR server':
      topic: ->
        app.listen port, @callback
        return
      teardown: ->
        app.close()

      'When searching npm2arch':
        topic: ->
          aur.info 'nodejs-npm2arch', config, @callback
          return
        'Then the AUR package description is returned': (err, result) ->
          assert.isNull err
          assert.deepEqual result, dummyPkg

      'When searching blablaabl':
        topic: ->
          aur.info 'blablalb', config, @callback
          return
        'Then an error is returned': (err, result) ->
          assert.isNotNull err
          assert.equal err.message, 'No results found'

      'When login with a good password':
        topic: ->
          aur.login 'user', 'passwd', config, @callback
          return
        'Then the Cookie Session ID is returned': (err, cookie) ->
          assert.isNull err
          assert.isNotNull cookie

      'When login with a bad password':
        topic: ->
          aur.login 'user', 'blabla', config, @callback
          return
        'Then an error is returned': (err, cookie) ->
          assert.isNotNull err
          assert.equal err.message, 'Wrong login or password'

      'When publishing with a good password':
        topic: ->
          aur.publish 'user', 'passwd', '/etc/passwd', config, @callback
          return
        'Everything is ok': (err, resp) ->
          assert.isNull err

      'When publishing a bad file':
        topic: ->
          aur.publish 'user', 'passwd', '/etc/group', config, @callback
          return
        'Everything is ok': (err, resp) ->
          assert.isNotNull err
          assert.equal 'Bad File', err.message

      'When publishing with a bad password':
        topic: ->
          aur.publish 'user', 'blabal', '/etc/passwd', config, @callback
          return
        'Then an error is returned': (err, resp) ->
          assert.isNotNull err
          assert.equal 'Wrong login or password', err.message

      'When publishing a non existing file':
        topic: ->
          aur.publish 'user', 'passwd', '/etc/fsqdhjbq', config, @callback
          return
        'Then an error is returned': (err, resp) ->
          assert.isNotNull err
          assert.include err.message, "ENOENT"

  .export module

port = 3000
config =
  url:
    base: "http://localhost:#{port}/"
    info: 'rpc.php?type=info&arg='
    login: 'login/'
    post: 'submit/'

dummyPkg =
  Maintainer: 'filirom1'
  ID: '53502'
  Name: 'nodejs-npm2arch'
  Version: '0.1.1-1'
  CategoryID: '1'
  Description: 'Convert NPM package to a PKGBUILD for ArchLinux'
  URL: 'https://github.com/Filirom1/npm2arch'
  License: 'MIT'
  NumVotes: '0'
  OutOfDate: '0'
  FirstSubmitted: '1319839817'
  LastModified: '1319839817'
  URLPath: '/packages/no/nodejs-npm2arch/nodejs-npm2arch.tar.gz'

app.use express.bodyParser()

# Search
app.get '/rpc.php', (req, res)->
  throw new Error 'arg not specified' if not req.query.arg
  if req.query.arg is 'nodejs-npm2arch'
    res.json type: 'info', results: dummyPkg
  else
    res.json type: 'error', results: 'No results found'

# Login
app.post '/#{config.url.login}/', (req, res)->
  if req.body.user is 'user' and req.body.passwd is 'passwd'
    res.cookie('AURSID','70bd1ee338d6767283b81e3e50c3610b', {httpOnly: true, secure: true, path: '/'})
  res.send '<html></html>'

# Upload
app.post "/#{config.url.post}" , (req, res) ->
  if req.files.pfile.name is 'passwd'
    res.send ''
  else
    res.send """
<html>
  <body>
    <div class="pkgoutput">Bad File</div>
  </body>
</html>
"""
