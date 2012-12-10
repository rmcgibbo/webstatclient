require = window.require

describe 'Cluster', ->
  Cluster = require('models/cluster')

  it 'can noop', ->
    