R = require "ramda"

toProxy = [
  "del"
  "get"
  "head"
  "patch"
  "post"
  "put"
]

# type Plugin = SuperAgent.Request -> SuperAgent.Request

# :: Plugin -> SuperAgent -> SuperAgent
#
# Given a plugin, returns a new SuperAgent request factory that installs the
# plugin in every request generated by the factory.
#
# If all you need is to use a plugin with an existing request, you may use
# request.use(plugin) instead.
#
withPlugin = R.curry (plugin, request) ->
  req = -> request.apply(null, arguments).use(plugin)
  f = (key) -> () -> request[key].apply(null, arguments).use(plugin)
  R.reduce((obj, key) -> R.assoc(key, f(key), obj))(req, toProxy)

# :: [Plugin] -> SuperAgent -> SuperAgent
#
# Returns a new SuperAgent request factory that installs all the given plugins
# on every request generated.
#
withPlugins = R.curry (plugins, request) ->
  withPlugin(R.reduceRight(R.compose, R.identity, plugins), request)

plugin =
  # :: String -> Plugin
  #
  # Add the `X-Tenant` header with the specified plant to the request.
  #
  withPlant: (plant) -> (req) ->
    req.set("X-Tenant", plant)
    req

  # :: String -> Plugin
  #
  # Prepend the given prefix to the url of the request.
  #
  withUrlPrefix: (prefix) -> (req) ->
    req.url = prefix + req.url
    req

  # :: String -> Plugin
  #
  # Add authorization to the request using the given bearer token.
  #
  bearerAuth: (token) -> (req) ->
    latestToken = localStorage.getItem('token') || localStorage.getItem('vi-jwt-token');
    req.set("Authorization", "Bearer #{latestToken}")
    req

module.exports = {withPlugin, withPlugins, plugin}

