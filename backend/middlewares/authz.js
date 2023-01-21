const user = require('../models/user')
const org = require('../models/org')

async function onlyUsers(req, res, next) {
    if (req.logedinOrg) {
        res.sendStatus(401)
        return
    }
    if (await org.findById(req.logedinUser.id)) {
        res.sendStatus(401)
        return
    }
    next()
}

async function onlyOrgs(req, res, next) {
    if (req.logedinUser) {
        res.sendStatus(401)
        return
    }
    if (await user.findById(req.logedinOrg.id)) {
        res.sendStatus(401)
        return
    }
    next()
}

async function isOrgEventOwner(req, res, next) {
    if (req.logedinUser) {
        next()
        return
    }
    let eventId = req.params.eventId
    let orgx = await org.findById(req.logedinOrg.id)
    orgx.orgEvents.includes(eventId) ? next() : res.sendStatus(401)
}


module.exports = {
    onlyUsers,
    isOrgEventOwner,
    onlyOrgs
}