const { validUserSchema, validOrgSchema, validEventSchema, validLoginSchema } = require("../models/schema");
const { RESPONSE, logError } = require('../utils/shared_funs');

const createValidationMiddlewear = (schema) => {
    return (req, res, next) => {
        let data
        if (req.body.userdata) data = req.body.userdata
        if (req.body.orgdata) data = req.body.orgdata
        if (req.body.eventdata) data = req.body.eventdata

        const { error } = schema.validate(data)
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
module.exports.validateEvent = createValidationMiddlewear(validEventSchema)
