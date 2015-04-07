createDomain = require('domain').create
browserify = require 'browserify-middleware'
React = require 'react'
extend = require 'node.extend'

locale = null
try
    locale = require 'locale'

router = require './router'
transform = require './transform'
prod = require './prod'
State = require './state'


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
        initialData =
            rootTagId: opts.rootTagId
            view: view
            params: params
            state: State.getInitial()
            locale: @req.locale
            localeData: @req.localeData
        initialDataJson = JSON.stringify(initialData)
        @res.render(opts.template, {
            component: component
            initialData: initialDataJson
            title: document?.title || ''
            locale: @req.locale
        })
        
    reactView = (view, params, opts) ->
        cmp = router.component(view)
        @res.reactRender(view, cmp, params, opts)
        
    (req, res, next) ->
        res.reactRender = reactRender.bind({req, res})
        res.reactView = reactView.bind({req, res})
        next()
        
        
module.exports.i18n = (locales, options) ->
    if !locale
        throw new Error('Locale is not installed. Please run `npm install locale`')
    
    options = extend(
        defaultLocale: locales[0]
        cookieName: 'lc'
        cookie: {}
    , options)
    
    i18n = locales.reduce((i18n, lc) ->
        localeData = options.loadData(lc)
        i18n[lc] =
            data: localeData
            lib: options.loadLib(localeData)
        i18n
    , {})
    
    locale.Locale['default'] = options.defaultLocale
    
    supported = new locale.Locales(locales)
    
    (req, res, next) ->
        
        req.setLocale = (lc, setCookie = true) ->
            (lc && locales.indexOf(lc) != -1) or lc = options.defaultLocale
            req.locale = lc
            req.localeData = i18n[lc].data
            req.i18n = i18n[lc].lib
            if setCookie
                res.cookie(options.cookieName, lc, options.cookie)
        
        lc = req.cookies[options.cookieName]
        if(!lc || locales.indexOf(lc) == -1)
            reqLocales = new locale.Locales(req.headers['accept-language'])
            lc = reqLocales.best(supported)
        req.setLocale(lc)
        
        next()
