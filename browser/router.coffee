React = require 'react'

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
        @render()
        history.pushState(@getState(), '', @url(@view, @params))
        
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
        
    component: (name, params = {}, method = 'get') ->
        React.createElement(namedRoutes.routesByNameAndMethod[name][method].component, params)

    react: (path, name, component, method = 'get') ->
        namedRoutes.add(method, path, null, {name})
        namedRoutes.routesByNameAndMethod[name][method].component = component
        
    reactGet: (path, name, component) ->
        @react(path, name, component, 'get')

    reactPost: (path, name, component) ->
        @react(path, name, component 'post')
        

module.exports = router
