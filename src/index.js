const R = require('ramda');

const toProxy = [
  'del',
  'get',
  'head',
  'patch',
  'post',
  'put',
];

// type Plugin = SuperAgent.Request -> SuperAgent.Request

// :: Plugin -> SuperAgent -> SuperAgent
//
// Given a plugin, returns a new SuperAgent request factory that installs the
// plugin in every request generated by the factory.
//
// If all you need is to use a plugin with an existing request, you may use
// request.use(plugin) instead.
//
const withPlugin = R.curry((plugin, request) => {
  const req = () => request.apply(null, arguments).use(plugin);
  const f = (key) => () => request[key].apply(null, arguments).use(plugin);
  return R.reduce((obj, key) => R.assoc(key, f(key), obj))(req, toProxy);
});

// :: [Plugin] -> SuperAgent -> SuperAgent
//
// Returns a new SuperAgent request factory that installs all the given plugins
// on every request generated.
//
const withPlugins = R.curry((plugins, request) => {
  return withPlugin(R.reduceRight(R.compose, R.identity, plugins), request);
});

const plugin = {
  // :: String -> Plugin
  //
  // Add the `X-Tenant` header with the specified plant to the request.
  //
  withPlant: (plant) => (req) => {
    req.set('X-Tenant', plant);
    return req;
  },

  // :: String -> Plugin
  //
  // Prepend the given prefix to the url of the request.
  //
  withUrlPrefix: (prefix) => (req) => {
    req.url = prefix + req.url;
    return req;
  },

  // :: String -> Plugin
  //
  // Add authorization to the request using the given bearer token.
  //
  bearerAuth: (token) => (req) => {
    req.set('Authorization', `Bearer ${token}`);
    return req;
  },
};

module.exports = {withPlugin, withPlugins, plugin};
