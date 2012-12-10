Spine = require('spine')

class Cluster extends Spine.Model
  @configure 'Cluster', 'name'
  @extend Spine.Model.Local
  
module.exports = Cluster