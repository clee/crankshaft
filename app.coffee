# Module dependencies.

connect = require "connect"
restify = require "restify"
Maildir = require "maildir"

app = module.exports = restify.createServer()

# Configuration
app.use connect.logger()
static_handler = connect.static "#{__dirname}/public"
app.get /\/public\/*/, (req, res, next) ->
	req.url = req.url.substr "/public".length
	static_handler req, res, next

# Routes
app.get '/', (req, res, next) ->
	# would be nice to just render without a redirect. Good Enough™ for now
	res.header 'Location', '/public/index.html'
	res.send 302
	next false

app.get '/messages', (req, res) ->
	md = new Maildir '/home/clee/sample'

	res.header 'Content-Type', 'text/event-stream'
	res.header 'Cache-Control', 'no-cache'
	res.header 'Connection', 'keep-alive'

	id = (new Date()).toLocaleTimeString()

	md.on 'newMessage', (message) ->
		constructMessage res, id, message

	md.files.forEach (f, i) ->
		md.loadMessage f, (message) ->
			constructMessage res, id, message
	md.monitor()
	res.on 'close', ->
		md.shutdown()

app.get '/messages/:id', (req, res) ->
	md = new Maildir '/home/clee/sample'
	id = req.params.id
	md.loadMessage id, (message) ->
		res.json message

constructMessage = (res, id, message) ->
	res.write "id: #{id}\n"
	res.write "event: message\n"
	res.write "data: #{JSON.stringify message?.headers}\n\n"

app.listen process.env.PORT || 3000
app.on 'listening', ->
	console.log "crankshaft server listening on port %d", app.address().port
