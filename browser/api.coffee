Promise = require 'bluebird'
uri = require 'lil-uri'

{BaseApiMethod, BaseApi} = require '../base/api'
{YError, tryUnpackError} = require './errors'
{Validator, ValidationContext} = require './validate'
State = require './state'


prefix = '/api'


buildParams = (params = {}) ->
    Object.keys(params).map((k) ->
        k + '=' + encodeURIComponent(params[k])
    ).join('&')

    
request = (method, url, params) ->
    params = buildParams(params)
    xhr = new XMLHttpRequest()
    new Promise((resolve, reject) ->
        xhr.addEventListener('error', reject)
        xhr.addEventListener('load', resolve)
        if method == 'POST'
            xhr.open(method, url, true)
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
            xhr.send(params)
        else
            url = uri(url)
            url.search(params)
            xhr.open(method, url.build(), true)
            xhr.send(null)
    ).then(-> xhr.responseText)
    .cancellable().catch(Promise.CancellationError, (e) ->
        xhr.abort()
        throw e
    )


class ApiMethod extends BaseApiMethod
    
    httpMethod: 'get'
    
    constructor: (@name, @params, @httpMethod) ->
    
    call: (params, v = true) ->
        Promise.resolve(if v then @validateAll(params) else params).then((params) =>
            request(@httpMethod, "#{prefix}/#{@name}", params)
            .then(JSON.parse).then((res) ->
                if res.success
                    State.set(res.state)
                    return res.data
                else
                    throw res.error
            ).catch((err) ->
                yerr = tryUnpackError(err)
                if !yerr
                    console.error?(err)
                throw yerr || new YError('Application error')
            )
        )
        


class Api extends BaseApi
    
    init: (@_methods, prefix_) ->
        prefix = prefix_
#        Validator.api = @
        ValidationContext.prototype.api = @
        @init = null
        
    
    
module.exports = new Api()
module.exports.ApiMethod = ApiMethod

