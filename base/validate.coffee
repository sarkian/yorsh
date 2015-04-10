Promise = require 'bluebird'
validatorLib = require 'validator'

{ParamError} = require './errors'


class BaseValidator
    
    _fn: null
    _fnMethod: null
    _args: []
    _msg: (pname) -> "Invalid parameter: #{pname}"
    _shared: false
        
    constructor: (fn, args, msg) ->
        @_fn = fn
        @_fnMethod = Promise.method(fn)
        @_args = args
        @_msg = msg
    
    msg: (@_msg) -> @
    fn: (@_fn) -> @
    shared: (@_shared = true) -> @
        
    validate: (pname, pval, context) ->
        context or context = new ValidationContext()
        @_fnMethod.apply(context, [pval].concat(@_args)).then((res) =>
            if res != true
                throw new ParamError(@getMsg(pname, context), pname, pval)
            true
        )
        
    validateDirect: (pname, pval, context) ->
        context or context = new ValidationContext()
        @_fn.apply(context, [pval].concat(@_args))
        
    getMsg: (pname, context) ->
        if typeof @_msg == 'function' then @_msg.call(context, pname) else @_msg
        
        

    @required: (msg = (n) -> "Required parameter: #{n}") ->
        new @(((val) -> val? and val isnt ''), [], msg)

    @alphanum: (msg) ->
        new @(((val) -> @v.isAlphanumeric(val)), [], msg)
        
    @email: (options, msg) ->
        if msg == undefined
            msg = options
            options = {}
        fn = (val, options) -> @v.isEmail(val, options)
        new @(fn, [options], msg)
        
    @phone: (locale, msg) ->
        new @(((val) -> @v.isMobilePhone()), [locale], msg)

    @len: (min, max, msg) ->
        if typeof max != 'number' && not msg?
            msg = max;
            max = undefined
        fn = (val, min, max) -> @v.isLength(val, min, max)
        new @(fn, [min, max], msg)

    @int: (msg) ->
        new @(((val) -> @v.isInt(val)), [], msg)

    @in: (values, msg) ->
        fn = (val, values) -> @v.isIn(val, values)
        new @(fn, [values], msg)
        
    @regex: (regex, msg) ->
        regex = regex.toString()
        fn = (val, expr, flags) -> new RegExp(expr, flags).test(val)
        new @(fn, [regex.replace(/^\/|\/[a-zA-Z]*$/g, ''), /[a-zA-Z]*$/.exec(regex)[0]], msg)

    @custom: (fn, msg) ->
        new @(fn, [], msg)

    @customArgs: (fn, args, msg) ->
        new @(fn, args, msg)
        
        
        
class ValidationContext
    
    v: validatorLib
    api: null
    allParams: {}
    
    constructor: (props) ->
        if !props
            return
        {@allParams} = props
        
        

module.exports =
    BaseValidator: BaseValidator
    ValidationContext: ValidationContext
