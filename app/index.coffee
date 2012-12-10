require('lib/setup')

Spine    = require('spine')
Clusters = require('controllers/clusters')

class App extends Spine.Controller
  constructor: ->
    super
    @contacts = new Clusters(['vsp-compute', 'certainty'])
    @append @contacts

    Spine.Route.setup()

module.exports = App
    