{BaseValidator, ValidationContext} = require '../base/validate'


class Validator extends BaseValidator
    
    # Context
    
    @api: null # Must be setted in api.init()
    
    
module.exports =
    BaseValidator: BaseValidator
    Validator: Validator
    ValidationContext: ValidationContext
