

class YError extends Error
    name: 'YError'
    @props: []
    constructor: (@message) ->

class ParamError extends YError
    name: 'ParamError'
    @props: ['param', 'value']
    constructor: (@message, @param, @value) ->

class AccessError extends YError
    name: 'AccessError'
    
    
module.exports = errors =
    YError: YError
    ParamError: ParamError
    AccessError: AccessError
    

module.exports.packError = (err) ->
    obj = {}
    ['name', 'message'].concat(errors[err.name].props).forEach (n) ->
        obj[n] = err[n]
    obj
    
module.exports.unpackError = unpackError = (obj) ->
    err = new errors[obj.name]()
    ['message'].concat(errors[obj.name].props).forEach (n) ->
        err[n] = obj[n]
    err
    
module.exports.isYError = isYError = (obj) ->
    errors[obj?.name]?.props?
    
module.exports.tryUnpackError = (obj) ->
    if isYError(obj) then unpackError(obj)
