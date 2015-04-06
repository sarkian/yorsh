module.exports = (initialData) ->
    
    window.React = require 'react'
    window.Y = require 'yorsh/browser'
    
    window.onload = ->
        root = document.getElementById(initialData.rootTagId)
        if root?
            Y.state.set(initialData.state)
            Y.router.init(initialData.rootTagId, initialData.view, initialData.params)
            
            
module.exports.getInitialData = (tagId) ->
    JSON.parse(document.getElementById(tagId)?.innerHTML)
