Spine = require('spine')
Cluster = require('models/cluster')
require('spine/lib/route')
timeago = require('timeago')


class TimeagoLoop
    # A little class that loops refreshing how long ago something was.
    set: (selector, time) ->
        # parameters: a jquery seelctor and a DateTime.
        # every minute, the innerHTML in the selector will be updated to show
        # how long ago the `time` was.
        
        @clear()        
        selector[0].innerHTML = timeago(time)
        @id = setInterval(->
            #console.log 'updated time'
            selector[0].innerHTML = timeago(time)
        , 60000)

    clear: ->
        if @id != undefined
            clearInterval(@id)



class NavBar extends Spine.Controller
    _highlight: (path) ->
        # set the css on the navbar to show which tab is currently active
        # path is supposed to be the current route.
        @_highlightItem $(button), path for button in @buttons.children() 
    
    _highlightItem: (item, highlight) ->
        if ///^#{$(item.children()[0]).attr('href')[1..]}.*$///.test highlight
            item.addClass 'active'
        else
            item.removeClass 'active'
            
    constructor: ->
        super
        @timeago_loop = new TimeagoLoop
        
        @html require('views/navbar')({clusters: Cluster.all()})
        
        # bind to the activation event, which the Cluster can emit
        Cluster.bind "activate", @activate
        
        # whenever a cluster triggers the "lastupdated" event, we need to reset
        # the timeago loop that draws the time-since-last-refresh in the navbar
        Cluster.bind "lastupdated", (cluster, time) =>
            @timeago_loop.set($('time.timeago'), time)
        
        
    activate: (cluster) =>
        # when a cluster activates, we redraw the highlighting in the navbar
        # note the code below depends on the fact that we're using the model
        # id as the route.
        @_highlight cluster.id
    
    elements:
        'ul': 'buttons'

module.exports = NavBar
