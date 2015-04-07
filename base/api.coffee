Promise = require 'bluebird'

{BaseValidator} = require './validate'

    
class BaseApiMethod

    validateAll: (args = {}) ->
        Promise.reduce(Object.keys(@params), (values, pname) =>
            @validateParam(pname, args[pname]).then (pval) ->
                if pval != undefined
                    values[pname] = pval;
                values
        , {})

    validate: (args = {}) ->
        Promise.reduce(Object.keys(args).filter((pname) => @params[pname]?), (values, pname) =>
            @validateParam(pname, args[pname]).then (pval) ->
                values[pname] = pval;
                values
        , {})

    validateParam: (pname, pval) ->
        Promise.reduce(@params[pname], (_, handler) ->
            if handler instanceof BaseValidator
                handler.validate(pname, pval)
            else if typeof handler == 'function'
                pval = handler(pval)
        , null).then(-> pval)
        
    validator: (pname) ->
        if !(@params[pname] instanceof Array)
            throw new Error("Undefined API method parameter: #{@name}:#{pname}")
        (pval) => @validateParam pname, pval
    

class BaseApi

    _methods: Object.create(null)
    _cache: Object.create(null)
    
    method: (name) ->
        if !(@methods[name] instanceof BaseApiMethod)
            throw new Error("Undefined API method: #{name}")
        @methods[name]
        
    call: (name, params, validate = true) ->
        @method(name).call(params, validate)
        
    cache: (key, name, params, validate) ->
        if key of @_cache
            return Promise.resolve(@_cache[key])
        @call(name, params, validate).then((res) => @_cache[key] = res)


module.exports =
    BaseApiMethod: BaseApiMethod
    BaseApi: BaseApi
