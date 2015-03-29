createDomain = require('domain').create
browserify = require 'browserify-middleware'
React = require 'react'
extend = require 'node.extend'

router = require './router'
transform = require './transform'
prod = require './prod'


Object.defineProperty(global, 'document',
    get: -> process.domain.document
    set: (d) -> process.domain.document = d
)


module.exports.domain = ->
    cnt = 0
    (req, res, next) ->
        domain = createDomain()
        domain.id = new Date().getTime() + cnt++
        domain.add req
        domain.add res
        domain.req = req
        domain.res = res
        domain.on('error', next)
        domain.run(next)
        
        
module.exports.browserify = (path, opts) ->
    opts = extend(
        extensions: ['.js', '.jsx', '.coffee']
        transform: transform.browserify.all()
        sourceMap: !prod
    , opts)
    browserify(path, opts)
    
    
module.exports.reactRender = (opts_) ->
    opts_ = extend(
        template: 'layout',
        rootTagId: 'root'
    , opts_)
    reactRender = (view, cmp, params = {}, opts) ->
        opts = extend(opts_, opts)
        global.document? or global.document = {}
        router.setView(view, params)
        component = React.renderToString(React.createElement(cmp, params))
        initialData = JSON.stringify({rootTagId: opts.rootTagId, view, params})
        @res.render(opts.template, {component, initialData, title: document?.title || ''})
    reactView = (view, params, opts) ->
        cmp = router.component(view)
        @res.reactRender(view, cmp, params, opts)
    (req, res, next) ->
        res.reactRender = reactRender.bind({req, res})
        res.reactView = reactView.bind({req, res})
        next()
        
        
