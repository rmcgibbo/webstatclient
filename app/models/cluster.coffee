Spine = require('spine')


class Cluster extends Spine.Model
    @configure 'Cluster', 'name', 'procs', 'nodes', 'freenodes', 'history', 'active'
    @extend Spine.Events
    
    server: "http://vspm42-ubuntu.stanford.edu"
    
    @retreive_all: ->
        # class method to pull the names of all the clusters from
        # the server
        $.get 'http://vspm42-ubuntu.stanford.edu/clusters', (e) =>
            for record, i in e.clusters
                c = new Cluster(record)
                c.save()
                c.populate()
            @trigger "fetched"
    
    
    populate: =>
        # pull info specific to this cluster
        @procs = null
        @nodes = null
        @freenodes = null
        @history = null
        @save()
        @refresh()
    
    refresh: =>
        $.get "#{@server}/cluster/#{@id}/procs", @populate_procs
        $.get "#{@server}/cluster/#{@id}/nodes", @populate_nodes
        $.get "#{@server}/cluster/#{@id}/freenodes", @populate_freenodes
        hours = 1
        $.get "#{@server}/cluster/#{@id}/history/#{hours}", @populate_history


    populate_procs : (payload) =>
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
            row[0] = new Date(row[0])
            table.addRow(row)

        #console.log(table)

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