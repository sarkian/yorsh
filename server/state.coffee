

initial = []


State =
    
    define: (name, get, set) ->
        if typeof get == 'function'
            State.__defineGetter__ name, get
        if typeof set == 'function'
            State.__defineSetter__(name, (v) ->
                set v
                State.setChanged name
            )
            
    defineShared: (name, get, set) ->
        State.define(name, get, set)
        initial.push(name)
            
    set: (state) ->
        State._changed instanceof Array or State._changed = []
        for k in Object.keys(state)
            State[k] = state[k]
            State.setChanged(k)
            
    setChanged: (name) ->
        if State._changed.indexOf(name) == -1
            State._changed.push name
            
    getInitial: ->
        state = {}
        initial.forEach((name) ->
            state[name] = State[name]
        )
        state
        
    getChanged: ->
        state = {}
        while name = State._changed.shift()
            state[name] = State[name]
        state
        
        
State.__defineGetter__('_changed', ->
    if !(process.domain.req._stateChanged instanceof Array)
        process.domain.req._stateChanged = []
    process.domain.req._stateChanged
)

State.__defineSetter__('_changed', (v) ->
    process.domain.req._stateChanged = v
)


module.exports = State

