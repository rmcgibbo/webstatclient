webstat (client)
----------------

This is the user-facing client side code for the webstat PBS monitoring system.

It is written in coffeescript, using the [Spine.js](http://spinejs.com/)
framework, some [Twitter Bootstrap](http://twitter.github.com/bootstrap/)
components for the navbar/layout, and [Google Charts](https://developers.google.com/chart/)
to draw the graphs.

To run the code, you should probably read the Spine
[getting started guide](http://spinejs.com/docs/started). You need to install
[Node](http://nodejs.org/) and the npm package manager. Then you can run a little
development server (hem) that will compile the coffeescript to javascript,
bundle all of the files up into one, and serve it. All of this is detailed in
the getting started guide.

One useful note is that you can make development easier by running the hem
server locally, and then starting your browser to ignore the same-origin policy
so that you can still make the ajax requests to the server. That way you can
have the server running tornado, your local client-side server running hem,
and not have to deal with something complicated like proxying them together.

Some directions here:
http://stackoverflow.com/questions/3102819/chrome-disable-same-origin-policy

I'm starting chrome on a max like this:
`$ /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security`

To put it into production, hem will bundle everything up into a single file that
you can serve -- with tornado -- as a static file. But because that also minifies
the javascript, its not so good for development and debugging.


todo
----
- add more clusters (certainty, biox3). This is mostly a server side issue.
- add more visualizations. what should they be? Perhaps let the user customize
  the time frame on the history graph.
- sync the colors between the graphs. Need to read how to specify the colors.
- move some of the logic here onto the server by making the server send JSON
  that is as close as possible to the format requested by the google charts API.
  This makes stuff easier since it moves logic from coffeescript into python.
- make the 'free nodes' section display some more interesting info when there
  aren't any free nodes.
- richer API -- maybe the use should be able to click on a node or user and get
  more info?
- can more of the application logic be moved into the Spine.js event system thats
  already built in (i.e. not using our own custom events) and the Spine.js AJAX
  abstractions?