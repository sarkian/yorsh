NamedRoutes = require 'named-routes'
uri = require 'lil-uri'


namedRoutes = new NamedRoutes()


buildUrl = (name, params = {}, method = 'get') ->
    route = namedRoutes.routesByNameAndMethod[name][method]
    url = route.generate(params)
    queryParams = Object.keys(params).filter((name) ->
        route.params.indexOf(name) < 0
    )
    if queryParams.length
        query = queryParams.reduce((query, name) ->
            query[name] = params[name];
            query
        , {})
        url = uri(url).query(query).build()
    url

    
    
module.exports = {namedRoutes, buildUrl}
