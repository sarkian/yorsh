State =
    
    set: (state) ->
        for k in Object.keys(state)
            this[k] = state[k]
            
            
module.exports = State
