Promise = require 'bluebird'
express = require 'express'
extend = require 'node.extend'

{namedRoutes, buildUrl} = require '../base/router'

httpMethods = require './methods'


router = express.Router()
namedRoutes.extendExpress4(router)


router.url = buildUrl

router.component = (name, method = 'get') ->
    namedRoutes.routesByNameAndMethod[name][method].component


getDRouter = ->
    if !process.domain.router
        process.domain.router = {view: null, params: {}}
    process.domain.router
    
    
router.getCurrentUrl = () ->
    process.domain.req.path
    
    
router.setView = (view, params = {}) ->
    dRouter = getDRouter()
    dRouter.view = view
    dRouter.params = params

    
router.go = (view, params = {}) ->
    router.setView(view, params)
    process.domain.res.redirect(router.url(view, params))
    
    
router.bindGo = ->


router.isActive = (view, params = {}) ->
    dRouter = getDRouter()
    view == dRouter.view

    
router.react = (path, name, component, method = 'get', before = ->) ->
    before = Promise.method(before)
    router[method](path, name, (req, res) ->
        params = extend(req[httpMethods[method]], req.params)
        before(req, res, params).then((ret) ->
            if !res._headerSent
                if typeof ret == 'object'
                    params = ret
                res.reactRender(name, component, params)
        )
    )
    namedRoutes.routesByNameAndMethod[name][method].component = component
    
    
router.reactGet = (path, name, component, before) ->
    router.react(path, name, component, 'get', before)
    
router.reactPost = (path, name, component, before) ->
    router.react(path, name, component, 'post', before)

    
    
module.exports = router
