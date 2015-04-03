module.exports = (dataTagId) ->
    
    window.React = require 'react'
    window.Y = require 'yorsh/browser'
    
    window.onload = ->
        initialData = JSON.parse(document.getElementById('initial-data')?.innerHTML)
        if initialData
            root = document.getElementById(initialData.rootTagId)
        if root?
            Y.state.set(initialData.state)
            Y.router.init(initialData.rootTagId, initialData.view, initialData.params)
