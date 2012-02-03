Crankshaft = Em.Application.create({
    ready: function() {
        var source = new EventSource('/messages');
        source.addEventListener('message', function(e) {
            var message = Crankshaft.Message.create(JSON.parse(e.data));
            Crankshaft.messagePreviews.addMessage(message);
        }, false);
        this._super();
    }
});

Crankshaft.Message = Em.Object.extend({
    datetime: Ember.computed(function() {
        return moment(this.date).calendar();
    }).property('date'),
});

Crankshaft.messagePreviews = Em.ArrayProxy.create({
    content: [],
    _idCache: {},
    addMessage: function(message) {
        var id = message.get("message-id");
        if (typeof this._idCache[id] === "undefined") {
            this.pushObject(message);
            this._idCache[id] = message.get("message-id");
        }
    },
    /*
    sortedMessages: function() {
        return this.content.sort(function(a, b) {
            return Date.parse(a.get('date')) - Date.parse(b.get('date'));
        });
    }.property("@each.date").cacheable() */
});

// just for example only
$('.email-msg').first().addClass('active');