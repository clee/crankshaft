# Module dependencies.

express = require "express"
Maildir = require "maildir"

app = module.exports = express.createServer()

# Configuration

app.configure ->
	# app.set 'views', "#{__dirname}/views"
	# app.set 'view engine', 'jade'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.static "#{__dirname}/public"

app.configure 'development', ->
	app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure 'production', ->
	app.use express.errorHandler()

# Routes
app.get '/', (req, res) ->
	# would be nice to just render without a redirect. Good Enough™ for now
	res.redirect '/index.html'

app.get '/messages', (req, res) ->
	md = new Maildir '/home/clee/tmp/Maildir'

	res.header 'Content-Type', 'text/event-stream'
	res.header 'Cache-Control', 'no-cache'
	res.header 'Connection', 'keep-alive'

	id = (new Date()).toLocaleTimeString()

	md.on 'newMessage', (message) ->
		constructMessage res, id, message

	md.files.forEach (f, i) ->
		md.loadMessage i, (message) ->
			constructMessage res, id, message
	md.monitor()

app.get '/messages/:id', (req, res) ->
	md = new Maildir '/home/clee/tmp/Maildir'
	id = req.params.id
	md.loadMessage id, (message) ->
		res.json message

constructMessage = (res, id, message) ->
	res.write "id: #{id}\n"
	res.write "event: message\n"
	res.write "data: #{JSON.stringify message?.headers}\n\n"

app.listen process.env.PORT || 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
