const user = require('../models/user')
const org = require('../models/org')
const { logError, catchFun, RESPONSE, logx } = require('../utils/shared_funs')

module.exports.onlyUsers = catchFun(
    async function (req, res, next) {
        if (req.logedinOrg) {
            res.sendStatus(401)
            return
        }
        if (!req.logedinUser) throw Error("USER IS NULL -ONLYUSERS")
        if (await org.findById(req.logedinUser.id)) {
            res.sendStatus(401)
            return
        }
        next()
    }
)

module.exports.onlyOrgs = catchFun(
    async function (req, res, next) {        
        if (req.logedinUser) {
            res.sendStatus(401)
            return
        }

        if (!req.logedinOrg) throw Error("ORG IS NULL -ONLYORGS")

        if (await user.findById(req.logedinOrg.id)) {
            res.sendStatus(401)
            return
        }
        next()
    }
)

module.exports.isOrgEventOwner = catchFun(
    async function (req, res, next) {
        if (req.logedinUser) {
            next()
            return
        }
        let eventId = req.params.eventId
        let orgx = await org.findById(req.logedinOrg.id)
        orgx.orgEvents.includes(eventId) ? next() : res.sendStatus(401)
    }
)
