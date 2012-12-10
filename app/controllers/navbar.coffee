Spine = require('spine')
Cluster = require('models/cluster')
require('spine/lib/route')
timeago = require('timeago')

class TimeagoLoop
    # A little class that loops refreshing how long ago something was
    set: (selector, time) ->
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
        
        Cluster.bind "lastupdated", (cluster, time) =>
            @timeago_loop.set($('time.timeago'), time)
        
        
    activate: (cluster) =>
        # this code depends on the route for each cluster being its
        # id
        @_highlight cluster.id
    
    elements:
        'ul': 'buttons'

module.exports = NavBar
