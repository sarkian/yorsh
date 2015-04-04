Promise = require 'bluebird'

{BaseValidator} = require './validate'

    
class BaseApiMethod

    validateAll: (args = {}) ->
        Promise.reduce(Object.keys(@params), (values, pname) =>
            @validateParam(pname, args[pname]).then (pval) ->
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
            else
                pval = handler(pval)
        , null).then(-> pval)
        
    validator: (pname) ->
        if !(@params[pname] instanceof Array)
            throw new Error("Undefined API method parameter: #{@name}:#{pname}")
        (pval) => @validateParam pname, pval
    

class BaseApi

    methods: {}
    
    method: (name) ->
        if !(@methods[name] instanceof BaseApiMethod)
            throw new Error("Undefined API method: #{name}")
        @methods[name]
        
    call: (name, params, validate = true) ->
        @method(name).call(params, validate)
        


module.exports =
    BaseApiMethod: BaseApiMethod
    BaseApi: BaseApi
