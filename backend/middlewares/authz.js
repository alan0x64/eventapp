const user = require('../models/user')
const org = require('../models/org')
const { logError } = require('../utils/shared_funs')

async function onlyUsers(req, res, next) {
    try {
        if (req.logedinOrg) {
            res.sendStatus(401)
            return
        }
        if (await org.findById(req.logedinUser.id)) {
            res.sendStatus(401)
            return
        }
        next()
    } catch (err) {
        logError(err)
        RESPONSE(res, 500, { error: err.message })

    }
}

async function onlyOrgs(req, res, next) {
    try {
        if (req.logedinUser) {
            res.sendStatus(401)
            return
        }
        if (await user.findById(req.logedinOrg.id)) {
            res.sendStatus(401)
            return
        }
        next()
    } catch (err) {
        logError(err)
        RESPONSE(res, 500, { error: err.message })

    }
}

async function isOrgEventOwner(req, res, next) {
    try {
        if (req.logedinUser) {
            next()
            return
        }
        let eventId = req.params.eventId
        let orgx = await org.findById(req.logedinOrg.id)
        orgx.orgEvents.includes(eventId) ? next() : res.sendStatus(401)
    } catch (err) {
        logError(err)
        RESPONSE(res, 500, { error: err.message })

    }
}


module.exports = {
    onlyUsers,
    isOrgEventOwner,
    onlyOrgs
}