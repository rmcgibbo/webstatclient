Spine = require('spine')
NavBar = require('controllers/navbar')
Body = require('controllers/body')
Cluster = require('models/cluster')



class Clusters extends Spine.Controller
    setupRoutes: =>
        @routes
            ':cluster_id': (cluster_id) ->
                # this throws an error right at the begining, becasuse
                # the first route gets triggered before the Models have
                # been created
                cluster = Cluster.find(cluster_id.match[0])
                cluster.active = true
                cluster.save()
                cluster.trigger 'activate'
    
    setupWebsocket: =>
        ws = new WebSocket("ws://vspm42-ubuntu.stanford.edu:/announce")
        ws.onmessage = (event) =>
            # we always send JSON over the wire
            data = JSON.parse(event.data)
            if data.name == 'annoucement' and data.payload == "refresh"
                @log 'refresh all'
                for cluster in Cluster.all()
                    cluster.refresh()
                    
        # set the heartbeat
        heartbeat_it = setInterval((=>
            ws.send(JSON.stringify(name : 'ping'))
        ), 10000)
        
        ws.onclose = () ->
            clearInterval(heartbeat_it)
            alert("Closed Socket!")
            
        ws.onerror = (event) ->
            clearInterval(heartbeat_it)
            console.log("ERROR")
            console.log(event.data)
            
        $('#pullfromdaemons').click ->
            status = ws.send(JSON.stringify(name : 'refresh'))
            console.log("Sent WS request. Status = #{status}")
    
    constructor: ->
        super
        @setupRoutes()
        
        Cluster.retreive_all()
        Cluster.bind "fetched", =>
            @navbar = new NavBar
            @body = new Body
            @append @navbar, @body
            @navigate "#{Cluster.first().id}"
            Cluster.first().trigger 'activate'
            @setupWebsocket()
            


    
    
module.exports = Clusters