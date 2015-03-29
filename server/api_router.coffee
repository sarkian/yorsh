{YError, packError} = require './errors'
router = require('express').Router()


httpMethods = require './methods'


Object.keys(httpMethods).forEach((httpMethod) ->
    store = httpMethods[httpMethod]
    fn = router[httpMethod].bind(router)
    router[httpMethod] = (method) ->
        fn('/' + method.name, (req, res) ->
            method.call(req[store]).then((data) ->
                res.send({ success: true, data: data })
            ).catch(YError, (err) ->
                res.send({ success: false, error: packError(err) })
            ).catch((err) ->
                console.error(if err instanceof Error then err.stack else err)
                res.send({ success: false, error: packError(new YError('Application error')) })
            )
        )
)




module.exports = router
