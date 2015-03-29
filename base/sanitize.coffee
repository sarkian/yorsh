v = require 'validator'



Sanitizers =
    
    dval: (dval) ->
        (val) ->
            if val? && val != '' then val else dval
                
                
    
module.exports = Sanitizers
