http         = require 'http'
express      = require 'express'
path         = require 'path'
fs           = require 'fs'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'
stylus       = require 'stylus'
# async        = require 'async'
debug        = require('debug')('capsika.co.uk')

module.exports = class App

  routes: () ->
    router = express.Router()
    _r = []
    _r.push router.get '/', (req, res, next) ->
      res.render 'index', title: 'capsika dus dnb lol'
    return _r

  constructor: () ->
    console.log 'App constructed'
    # Instantiate Express and add middleware.
    @app = express()
    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded extended: true
    @app.use cookieParser()
    # Set up the view rendering.
    @app.set 'views', path.join __dirname, 'views'
    @app.set 'view engine', 'hbs'
    # Compile stylus files.
    @compileStylus()
    # Serve static files from the /public directory.
    @app.use express.static path.join __dirname, 'public'
    # Add the routes.
    @routes().forEach (route) => @app.use '/', route
    # Create the server.
    @server = http.createServer @app
    # Assign event callbacks.
    @server.on 'listening', @onListening
    @server.on 'error', @onError

  start: (_port = 3001) ->
    console.log 'App started'
    # Set the port.
    port = _port or process.env.PORT or 3001
    @app.set 'port', port
    # Listen on port.
    @server.listen port
    console.log "Listening on port #{port}"

  stop: () ->
    console.lgo 'App stopped'

  onListening: () ->

  onError: (err) ->
    switch err.code
      when 'EADDRINUSE'
        console.error 'Port is already in use'
        process.exit 1
      else
        throw err

  compileStylus: () ->
    stylusOutput = ''
    fs.readdirSync("#{__dirname}/styles").forEach (file) ->
      if ~file.indexOf '.styl'
        file = "#{__dirname}/styles/#{file}"
        stylusOutput += "\n#{fs.readFileSync(file)}"
    outputFile = "#{__dirname}/public/css/style.css"
    stylus.render stylusOutput,
      filename: outputFile
    , (err, css) ->
      if err then throw err
      fs.writeFileSync outputFile, css
