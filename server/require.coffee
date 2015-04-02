fs = require 'fs'
transform = require './transform'
options = transform.options


installed =
    jsx: false
    coffee: false
    
    
module.exports.installJsx = ->
    if installed.jsx
        return
    installed.jsx = true
    
    transform.compileJsx ''
    
    reqfn = (module, filename) ->
        src = fs.readFileSync filename, 'utf8'
        module._compile transform.compileJsx(src, filename), filename
        
    options.jsxExtensions.forEach((ext) ->
        require.extensions[ext] = reqfn
    )
    
    
module.exports.installCoffee = ->
    if installed.coffee
        return
    installed.coffee = true
    
    reqfn = (module, filename) ->
        src = fs.readFileSync filename, 'utf8'
        src = transform.compileCoffee src, filename
        if transform.options.jsxInCoffee
            src = transform.compileJsx src, filename
        module._compile src, filename
        
    options.coffeeExtensions.forEach((ext) ->
        require.extensions[ext] = reqfn
    )
