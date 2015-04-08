React = require 'react'
Promise = require 'bluebird'

{namedRoutes, buildUrl} = require '../base/router'


router =
    
    root: null
    view: null
    params: {}
    
    init: (rootTagId, @view, @params) ->
        @root = document.getElementById(rootTagId)
        window.addEventListener('popstate', (e) =>
            {@view, @params} = e.state
            @renderBefore(@view, @params)
        )
        history.replaceState(@getState(), '', @getCurrentUrl())
        if @view
            @render(@view, @params)
        
    go: (@view, @params = {}) ->
        history.pushState(@getState(), '', @url(@view, @params))
        @renderBefore(@view, @params)
        
    renderBefore: (view, params) ->
        params = Object.create(params)
        @before(view)(null, null, params).then((ret) =>
            if typeof ret == 'object'
                params = ret
            @render(view, params)
        )
        
    render: (view, params) ->
        React.render(@component(view, params), @root)
        
    getState: ->
        view: @view
        params: @params
        
    isActive: (view, params = {}) ->
        view == @view
        
    bindGo: (view, params) ->
        => @go view, params

    getCurrentUrl: () ->
        location.pathname + location.search
        
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
