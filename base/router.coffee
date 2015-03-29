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


compareParams = (x, y) ->
    if x == y
        return true
    if typeof x != typeof y
        return false
    for own p of x
        if !y.hasOwnProperty(p)
            return false
        if x[p] != y[p]
            return false
    for p of y
        if y.hasOwnProperty(p) && !x.hasOwnProperty(p)
            return false
    true
    
    
    
module.exports = {namedRoutes, buildUrl, compareParams}
