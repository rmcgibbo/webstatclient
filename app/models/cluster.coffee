Spine = require('spine')

# This is the place where "state" is controlled in our application. This
# class also signals all of the "events" that the controllers listen on.
    
# the events are "fetched", "refresh", "lastupdated".
# fetched is triggered when the Clusters get created, this happens from an
# ajax call that retrieves the names of all of the clusters.

# "refresh" gets triggered with an argument, "message", that says, 'hey, I just
# received new data about graph/table X'.

# lastupdated is a bit of a hack. It gets triggered by just one of the ajax
# calls, with a message that contains the timestamp on the data supplied by the
# server, so we know how recent our data is.

class Cluster extends Spine.Model
    # every instance variable that can be manipulated like a database field
    # needs to be displayed here
    @configure 'Cluster', 'name', 'procs', 'nodes', 'freenodes', 'history', 'active'
    @extend Spine.Events
    
    server: "http://vspm42-ubuntu.stanford.edu"
    
    @retreive_all: ->
        # class method to pull the names of all the clusters from the server.
        # this is sort of a multiple-constructor
        $.get 'http://vspm42-ubuntu.stanford.edu/clusters', (e) =>
            for record, i in e.clusters
                # the fields in the recort include 'name' and 'id'. It's also
                # setting one of the clusters to 'active'.
                c = new Cluster(record)
                c.save()
                c.populate()
            @trigger "fetched"
    
    
    populate: =>
        # this is basically the initializer for a single class. The idea
        # is to pull in all of the data.
        
        # first mark all of the entries as null, since we dont have them,
        @procs = null
        @nodes = null
        @freenodes = null
        @history = null
        @save()
        
        # then refresh -- go get the data (ajax)
        @refresh()
    
    refresh: =>
        # this is called either on initial pageload by populate, or whenever
        # the Clusters controller tells us to update (when it receives news
        # over the websocket)
        
        $.get "#{@server}/cluster/#{@id}/procs", @populate_procs
        $.get "#{@server}/cluster/#{@id}/nodes", @populate_nodes
        $.get "#{@server}/cluster/#{@id}/freenodes", @populate_freenodes
        hours = 1
        $.get "#{@server}/cluster/#{@id}/history/#{hours}", @populate_history


    populate_procs : (payload) =>
        # translate the server's JSON response onto a google chart object,
        # that is (almost) ready for rendering to the screen.
        
        # these need to be fat arrow so that they can be used as a callback
        # and save their results as instance variables in the class scope
        table = new google.visualization.DataTable()
        table.addColumn('string', 'User')
        table.addColumn('number', 'Procs')
        for row in payload.procs
            # payload is 'Procs', 'User', so we need to reverse it
            table.addRow([row[1], row[0]])

        options =
            chartArea: {'width': '100%', 'height': '80%'},

        @procs = 
            table: table
            options: options
        @save()
        
        @trigger "refresh", "procs"
        @trigger "lastupdated", payload.time
      
    populate_nodes: (payload) => 
        # these need to be fat arrow so that they can be used as a callback
        # and save their results as instance variables in the class scope
        
        table = new google.visualization.DataTable()
        table.addColumn('string', 'Status')
        table.addColumn('number', 'Number')
        for row in payload.nodes
            # payload is 'Procs', 'User', so we need to reverse it
            table.addRow([row[1], row[0]])

        options =
            chartArea: {'width': '100%', 'height': '80%'},
            #title: "Nodes - #{payload.cluster}"

        @nodes = 
            table: table
            options: options
        @save()
        @trigger "refresh", "nodes"
    
    populate_history: (payload) => 
        # these need to be fat arrow so that they can be used as a callback
        # and save their results as instance variables in the class scope
        
        table = new google.visualization.DataTable()
        for heading in payload.headings
            table.addColumn(heading.type, heading.name)

        for row in payload.table
            # hackish. Sorry. I know that the first column is a date string, which
            # needs to be converted to a javascript date object. 
            # a better solution would be to look at headings.type
            row[0] = new Date(row[0])
            table.addRow(row)

        options =
            chartArea: {'width': '100%', 'height': '80%'}
            pointSize: 3

        @history = 
            table: table
            options: options
            
        @save()
        @trigger "refresh", "history"
    
    populate_freenodes: (payload) =>
        @freenodes = payload.data
        @save()
        @trigger "refresh", "freenodes"
    
module.exports = Cluster