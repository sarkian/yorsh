api = require './api'
router = require './router'
state = require './state'
init = require './init'
{YError, ParamError, AccessError} = require './errors'
{Validator} = require './validate'

module.exports =
    
    whereAmI: -> 'browser'
        
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
    locale: null
    i18n: null
    
    # browser
    init: init
    