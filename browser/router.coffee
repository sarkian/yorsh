React = require 'react'
Promise = require 'bluebird'

{namedRoutes, buildUrl, compareParams} = require '../base/router'


router =
    
    root: null
    view: null
    params: {}
    
    init: (rootTagId, @view, @params) ->
        @root = document.getElementById(rootTagId)
        if @view
            @render()
        window.addEventListener('popstate', (e) =>
            @setState(e.state)
        )
#        history.replaceState(@getState(), '', @url(@view, @params))
        history.replaceState(@getState(), '', location.pathname + location.search)
        
    go: (@view, @params = {}) ->
        @before(@view)().then(=>
            @render()
            history.pushState(@getState(), '', @url(@view, @params))
        )
        
    bindGo: (view, params) ->
        => @go view, params
        
    isActive: (view, params = {}) ->
        view == @view # && compareParams(params, @params)
        
    render: ->
        React.render(@component(@view, @params), @root)
        
    getState: ->
        view: @view
        params: @params
        
    setState: (state) ->
        {@view, @params} = state
        @render()
    
    url: buildUrl
    
    before: (name, method = 'get') ->
        namedRoutes.routesByNameAndMethod[name][method].before
        
    component: (name, params = {}, method = 'get') ->
        React.createElement(namedRoutes.routesByNameAndMethod[name][method].component, params)

    react: (path, name, component, method = 'get', before = ->) ->
        namedRoutes.add(method, path, null, {name})
        namedRoutes.routesByNameAndMethod[name][method].before = Promise.method(before)
        namedRoutes.routesByNameAndMethod[name][method].component = component
        
    reactGet: (path, name, component, before) ->
        @react(path, name, component, 'get', before)

    reactPost: (path, name, component, before) ->
        @react(path, name, component 'post', before)
        

module.exports = router
