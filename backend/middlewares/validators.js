const {validPasswordSchema, validUserSchema, validOrgSchema, validEventSchema, validLoginSchema,validUpdateOrgSchema, validCheckInOutSchema } = require("../models/schema");
const { RESPONSE, logError,logx } = require('../utils/shared_funs');

const createValidationMiddlewear = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate({...req.body})
        if (error) {
            logError(error)
            return RESPONSE(res, 400,error.message)
        }
        next()
    }
}

module.exports.validateLogin = createValidationMiddlewear(validLoginSchema)
module.exports.validateUser = createValidationMiddlewear(validUserSchema)
module.exports.validateOrg = createValidationMiddlewear(validOrgSchema)
module.exports.validateUpdateOrg = createValidationMiddlewear(validUpdateOrgSchema)
module.exports.validatePassword = createValidationMiddlewear(validPasswordSchema)
module.exports.validateEvent = createValidationMiddlewear(validEventSchema)
module.exports.validateCheckInOut = createValidationMiddlewear(validCheckInOutSchema)

