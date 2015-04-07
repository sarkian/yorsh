api = require './api'
router = require './router'
state = require './state'
config = require './config'
{YError, ParamError, AccessError} = require './errors'
{Validator} = require './validate'

module.exports =
    
    whereAmI: -> 'server'
        
    # classes
    YError: YError
    ParamError: ParamError
    AccessError: AccessError
    ApiMethod: api.ApiMethod
    Validator: Validator
    
    # common
    api: api
    router: router
    state: state
    
    # server
    loadConfig: (conf) -> config.load(@config = conf); @loadConfig = null
    config: config.config
    prod: require './prod'
    transform: require './transform'
    require: require './require'
    middleware: require './middleware'
    api_router: require './api_router'
    
    db: null
    models: null
    
    
module.exports.__defineGetter__('session', -> process.domain.req.session)

module.exports.__defineGetter__('locale', -> process.domain.req.locale)

module.exports.__defineGetter__('i18n', -> process.domain.req.i18n)

module.exports.__defineGetter__('setLocale', -> process.domain.req.setLocale)
    
