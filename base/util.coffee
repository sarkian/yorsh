module.exports =

    compareParams: (x, y) ->
        if x == y
            return true
        if typeof x != typeof y
            return false
        for own p of x
            if !y.hasOwnProperty(p)
                return false
            if x[p] != y[p]
                return false
        for p of y
            if y.hasOwnProperty(p) && !x.hasOwnProperty(p)
                return false
        true
            