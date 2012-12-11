Spine = require('spine')
Cluster = require('models/cluster')
require('spine/lib/route')

# This controller renders the main part of the page. It needs to respond
# appropriately when the user switches tabs.

# the main events are "refresh" and "activate". "refresh" gets triggered
# whenever new data comes from the server. the event gets triggered with a
# message, which is the data element that got updated (i.e. which graph)

# the activate event gets triggered whenever the user switches tabs.

# during either of this events, we want to redraw the page that the user is
# currently on. this requires saving state about which page is active somewhere.
# My solution to this was to add "active" as a field in the Cluster model. There
# is probably a cleaner way to do this


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
        # this renders the html of the page
        @html require('views/body')(cluster: cluster)
        # and this draws the content
        @draw(cluster)
    
    draw : (cluster, msg="all") =>
        # redraw the page. Only redraw elements that are part of the "active"
        # cluster. if the event has a message, 'msg' refers to which
        # element got new data. So just update that one.
        
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