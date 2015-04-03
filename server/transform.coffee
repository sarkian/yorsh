transformTools = require 'browserify-transform-tools'

React = null
try
    React = require 'react-tools'

CoffeeScript = null
try
    CoffeeScript = require 'coffee-script'

config = require('./config')
api = require './api'
#prod = require './prod'


options = module.exports.options =
    jsx:
        harmony: false
    coffee:
        bare: true
    jsxExtensions: ['.jsx']
    coffeeExtensions: ['.coffee']
    jsxInCoffee: true
    
    
compileJsx = module.exports.compileJsx = (src, filename) ->
    if !React
        throw new Error('React is not installed. Please run `npm install react-tools`.')
    filename?.length? > 0 or filename = '<code>'
    try
        React.transform(src, options.jsx)
    catch e
        throw new Error("JSX transform error: #{filename}: #{e.toString()}")
        
        
compileCoffee = module.exports.compileCoffee = (src, filename) ->
    if !CoffeeScript
        throw new Error('CoffeeScript is not installed. Please run `npm install coffee-script`.')
    filename?.length? > 0 or filename = '<code>'
    try
        CoffeeScript.compile(src, options.coffee)
    catch e
        throw new Error("CoffeeScript transform error: #{filename}: #{e.toString()}")
        
        
        
        
browserify = module.exports.browserify =
    
    
    require: ->
        transformTools.makeRequireTransform(
            'yorshRequireTransform',
            {evaluateArguments: true},
            (args, opts, cb) ->
                if !/^yorsh(\/|$)/.test(args[0]) ||
                            /^yorsh\/browser(\/|$)/.test(args[0]) ||
                            /^yorsh\/components(\/|$)/.test(args[0])
                    return cb()
                rs = "require('#{args[0].replace(/^yorsh/, 'yorsh/browser')}')"
                if !api._browserInited #|| api._browserInited == opts.file
                    api._browserInited = opts.file
                    methods = api.getRoutedMethods()
                    methodsPack = Object.keys(methods).map((name)->
                        JSON.stringify(name) + ': ' + methods[name].pack()
                    ).join(', ')
                    prefix = JSON.stringify(config.config.api?.prefix || '/api')
                    rs = "(function(Y) {
                        var ApiMethod = Y.ApiMethod,
                            Validator = Y.Validator;
                        Y.api.init({#{methodsPack}}, #{prefix});
                        return Y;
                    })(require('yorsh/browser'))"
                cb(null, rs)
        )
        
        
    coffee: ->
        transformTools.makeStringTransform('yorshCoffeeTransform',
            {includeExtensions: options.coffeeExtensions},
            (src, opts, cb) ->
                src = compileCoffee(src, opts.file)
                if options.jsxInCoffee
                    src = compileJsx(src, opts.file)
                cb(null, src)
        )
        
    
    jsx: ->
        transformTools.makeStringTransform('yorshJsxTransform',
            {includeExtensions: options.jsxExtensions},
            (src, opts, cb) ->
                cb(null, compileJsx(src, opts.file))
        )
    
    
    
module.exports.browserify.all = (more = []) ->
    [
        browserify.coffee()
        browserify.jsx()
        browserify.require()
    ].concat(more)
