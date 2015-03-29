{BaseValidator} = require '../base/validate'


class Validator extends BaseValidator
    
    pack: ->
        "new Validator(#{@_fn.toString()}, #{@packArgs()}, #{@packMsg()})"

    packArgs: ->
        '[' + @_args.map((arg) ->
            if arg == undefined then 'undefined' else JSON.stringify(arg)
        ).join(', ') + ']'

    packMsg: ->
        if typeof @_msg == 'function' then @_msg.toString()
        else JSON.stringify(@_msg)
        
    

# Context getters

Object.defineProperty(Validator, 'api', get: -> require './api')


        
module.exports =
    BaseValidator: BaseValidator
    Validator: Validator

