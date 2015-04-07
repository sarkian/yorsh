Promise = require 'bluebird'

{BaseApiMethod, BaseApi} = require '../base/api'
{BaseValidator} = require './validate'
{YError} = require './errors'
S = require '../base/sanitize'



class ApiMethod extends BaseApiMethod
    
    httpMethod: null

    constructor: (@name, @params, fn) ->
        for own pname, handlers of @params
            handlers instanceof Array or @params[pname] = [handlers]
        @fn = Promise.method(fn)
        
    call: (args = {}, v = true) ->
        Promise.resolve(if v then @validateAll(args) else args).then(@fn)
        
    route: (httpMethod) ->
        require('./api_router')[httpMethod.toLowerCase()](@)
        @httpMethod = httpMethod.toUpperCase()
        
    pack: ->
        "new ApiMethod(#{JSON.stringify(@name)}, #{@packParams()}, #{JSON.stringify(@httpMethod)})"
        
    packParams: ->
        '{' + Object.keys(@params).map((pname) =>
            pname + ': [' + @params[pname].filter((h) ->
                h instanceof BaseValidator && h._shared
            ).map((h) ->
                h.pack()
            ).join(', ') + ']'
        ).join(', ') + '}'

        

class Api extends BaseApi
    
    _browserInited: false
    
    getRoutedMethods: ->
        methods = {}
        for own name, method of @_methods
            if method.httpMethod
                methods[name] = method
        methods
    
    define: (name, params, fn) ->
        if arguments.length is 2
            fn = params
            params = {}
        @_methods[name] = new ApiMethod(name, params, fn)

        
        
module.exports = new Api()
module.exports.ApiMethod = ApiMethod
