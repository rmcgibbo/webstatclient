Spine = require('spine')
Cluster = require('models/cluster')
require('spine/lib/route')


class Body extends Spine.Controller
    constructor : ->
        super
        
        $.get '/procs', (e) ->
            alert e
            
        
    activate : (cluster) ->
        @log "body", cluster
        @html require('views/body')(cluster: cluster)
        
module.exports = Body