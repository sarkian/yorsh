Promise = require 'bluebird'

{ParamError} = require './errors'


class BaseValidator
    
    _fn: (pval) -> true
    _args: []
    _msg: (pname) -> "Invalid parameter: #{pname}"
    _shared: false
        
    constructor: (fn, args, msg) ->
        if fn? then @_fn = fn
        if args? then @_args = args
        if msg? then @_msg = msg
    
    msg: (@_msg) -> @
    fn: (@_fn) -> @
    shared: (@_shared = true) -> @
        
    validate: (pname, pval) ->
        Promise.method(@_fn).apply(@constructor, [pval].concat(@_args)).then((res) =>
            if res != true
                throw new ParamError(@getMsg(pname), pname, pval)
            true
        )
        
    getMsg: (pname) ->
        if typeof @_msg == 'function' then @_msg.call(@constructor, pname) else @_msg
        
        
    # Context
        
    @v: require 'validator'

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
        
        

module.exports =
    BaseValidator: BaseValidator
