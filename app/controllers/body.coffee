Spine = require('spine')
Cluster = require('models/cluster')
require('spine/lib/route')


class Body extends Spine.Controller
    constructor : ->
        super
        # the refresh event comes when we get new data from server.
        # It's triggered by the ajax callback in the model
        Cluster.bind "refresh", @draw
        # the activate event comes when the user switches tabs.
        # its triggered in the routing
        Cluster.bind "activate", @activate

    activate : (cluster) =>
        # this callback is activated when the user switches between tabs
        #@log 'activating body'
        @html require('views/body')(cluster: cluster)
        @draw(cluster)
    
    draw : (cluster, msg="all") =>
        #@log 'draw', cluster, msg, cluster.active, cluster.procs
        if cluster.active
            if cluster.procs != null and (msg == 'all' or msg == 'procs')
                @log "drawing procs"
                chart = new google.visualization.PieChart($('#chart1')[0])
                chart.draw(cluster.procs.table, cluster.procs.options)

            if cluster.nodes != null and (msg == 'all' or msg == 'nodes')
                @log "drawing nodes"
                chart = new google.visualization.PieChart($('#chart2')[0])
                chart.draw(cluster.nodes.table, cluster.nodes.options)
            
            if cluster.freenodes != null and (msg == 'all' or msg == 'freenodes')
                @log "drawing freenodes"
                html = require('views/freenodes')(nodes: cluster.freenodes)
                $('.nodetable').html(html)
        
            if cluster.history != null and (msg == 'all' or msg == 'history')
                @log 'drawing history'
                chart = new google.visualization.LineChart($('#chart3')[0])
                chart.draw(cluster.history.table, cluster.history.options)

        
module.exports = Body