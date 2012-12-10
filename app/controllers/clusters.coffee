Spine = require('spine')
NavBar = require('controllers/navbar')
Body = require('controllers/body')
Cluster = require('models/cluster')



class Clusters extends Spine.Controller
    constructor: ->
        super
        @log('controllsers.clusters contrctor')

        a = new Cluster(name : 'cluster1')
        b = new Cluster(name : 'cluster2')
        c = new Cluster(name : 'cluster3')
        a.save()
        b.save()
        c.save()
        
        @navbar = new NavBar
        @body = new Body

        @append @navbar, @body
        @setupRoutes()
        Cluster.fetch()
        
        @log('/controllsers.clusters contrctor')

    
    setupRoutes: ->
        @routes
            ':cluster': (cluster) ->
                cluster = Cluster.find(cluster.match[0])
                @navbar.activate cluster
                @body.activate cluster
            '/': ->
                cluster = Cluster.first()
                @navbar.activate cluster
                @body.activate cluster
    
module.exports = Clusters