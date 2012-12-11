Spine = require('spine')
NavBar = require('controllers/navbar')
Body = require('controllers/body')
Cluster = require('models/cluster')

# Most of the action in the app is here in the controllers. This is the main
# controller. It delegates the work for rendering the navar and the body
# to those controllers respectively.

# The most tricky (buggy) part of the archicecture -- that I haven't really
# figured out how to do well -- is handing the initialization of data.
# When the app starts, it has no data. The data gets populated by ajax requests
# to the server.

# Since the routing (tabs) depend on what clusters are available, it's hard to
# do the very first route correctly.

# The events that we signal and respond to are "fetched", "refresh", and
# "activate". These are all events on the Cluster class. "fetched" gets triggered
# on the ajax callback that defines which clusters we have. This just gets
# their names, but not any of the data to render the graphs. Nevertheless, this
# is enough to define the routes.

class Clusters extends Spine.Controller
    setupRoutes: =>
        @routes
            # when the user naviages to /#<anything> we simply
            # look for that to be the "id" of a cluster and then activate
            # that cluster
            ':cluster_id': (cluster_id) ->
                # this throws an error right at the begining, becasuse
                # the first route gets triggered before the Models have
                # been created
                cluster = Cluster.find(cluster_id.match[0])
                cluster.active = true
                cluster.save()
                cluster.trigger 'activate'
    
    setupWebsocket: =>
        # part of the communication with the server is over websockets, which
        # lets the server "push" a notification to us saying "hey, I have new
        # data". But since the websocket support within the serverside framework
        # (and here in the client side framework) is not great, instead of
        # actually pushing the data over the websocket, we're just using it for
        # a notification.
        
        ws = new WebSocket("ws://vspm42-ubuntu.stanford.edu:/announce")
        ws.onmessage = (event) =>
            # we always send JSON over the wire
            data = JSON.parse(event.data)
            if data.name == 'annoucement' and data.payload == "refresh"
                @log 'refresh all'
                
                # trigger the clusters to refresh their data via ajax.
                for cluster in Cluster.all()
                    cluster.refresh()
                    
        # set the heartbeat
        
        # I had some experience with the websocket dieing... I'm not really
        # sure if this was the cause, but sending these heartbeat signals
        # every 10 seconds seems to help.
        heartbeat_it = setInterval((=>
            ws.send(JSON.stringify(name : 'ping'))
        ), 10000)
        
        ws.onclose = () ->
            clearInterval(heartbeat_it)
            # a nicer alert would be good.
            alert("Closed Socket!")
            
        ws.onerror = (event) ->
            clearInterval(heartbeat_it)
            console.log("ERROR")
            console.log(event.data)
        
        
        # manually set up to listen on the "Refresh" button in the navbar
        # via jquery, and bind this to a websocket message.
        $('#pullfromdaemons').click ->
            status = ws.send(JSON.stringify(name : 'refresh'))
            console.log("Sent WS request. Status = #{status}")
    
    constructor: ->
        super
        # action starts here
        @setupRoutes()
        
        Cluster.retreive_all()
        Cluster.bind "fetched", =>
            # setup the two other controllers
            @navbar = new NavBar
            @body = new Body
            @append @navbar, @body
            # now that we have enough info for the routes to actually make sense
            # redirect the user to the first cluster.
            @navigate "#{Cluster.first().id}"
            Cluster.first().trigger 'activate'  # is this necessary?
            @setupWebsocket()
            


    
    
module.exports = Clusters