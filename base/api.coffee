Promise = require 'bluebird'

{BaseValidator, ValidationContext} = require './validate'

    
class BaseApiMethod

    validateAll: (args = {}, context) ->
        context or context = new ValidationContext({allParams: args})
        Promise.reduce(Object.keys(@params), (values, pname) =>
            @validateParam(pname, args[pname], context).then (pval) ->
                if pval != undefined
                    values[pname] = pval;
                values
        , {})

    validate: (args = {}, context) ->
        context or context = new ValidationContext({allParams: args})
        Promise.reduce(Object.keys(args).filter((pname) => @params[pname]?), (values, pname) =>
            @validateParam(pname, args[pname], context).then (pval) ->
                values[pname] = pval;
                values
        , {})

    validateParam: (pname, pval, context) ->
#        context instanceof ValidationContext or context = new ValidationContext()
        if !(context instanceof ValidationContext)
            context = new ValidationContext({allParams: context})
        Promise.reduce(@params[pname], (_, handler) ->
            if handler instanceof BaseValidator
                handler.validate(pname, pval, context)
            else if typeof handler == 'function'
                pval = handler(pval)
        , null).then(-> pval)
        
    validator: (pname) ->
        if !(@params[pname] instanceof Array)
            throw new Error("Undefined API method parameter: #{@name}:#{pname}")
        (pval, allParams) => @validateParam(pname, pval, new ValidationContext({allParams}))
    

class BaseApi

    _methods: Object.create(null)
    _cache: Object.create(null)
    
    method: (name) ->
        if !(@_methods[name] instanceof BaseApiMethod)
            throw new Error("Undefined API method: #{name}")
        @_methods[name]
        
    call: (name, params, validate = true) ->
        @method(name).call(params, validate)
        
    cache: (key, name, params, validate) ->
        if key of @_cache
            return Promise.resolve(@_cache[key])
        @call(name, params, validate).then((res) => @_cache[key] = res)


module.exports =
    BaseApiMethod: BaseApiMethod
    BaseApi: BaseApi
