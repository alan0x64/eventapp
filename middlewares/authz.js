const user = require('../models/user')
const org = require('../models/org')
const event = require('../models/event')

async function onlyUsers(req, res, next) {
    if (req.logedinOrg.id) {
        res.sendStatus(201)
        return
    }
    let data = await org.findById(req.logedinUser.id)
    if (data.length != 0) {
        res.sendStatus(201)
        return
    }
    next()
}

async function onlyOrgs(req, res, next) {
    if (req.logedinUser.id) {
        res.sendStatus(201)
        return
    }

    let data = await user.findById(req.logedinOrg.id)
    if (data.length != 0) {
        res.sendStatus(201)
        return
    }
    next()
}

async function isOrgEventOwner(req, res, next) {
    if (req.logedinUser.id) {
        next()
    }

    let eventId = req.params.event
    let orgx = await org.findById(req.logedinOrg.id)
    orgx.orgEvents.includes(eventId) ? next() : res.sendStatus(201)
}

async function ImageAuthz(req, res, next) {
}


module.exports = {
    onlyUsers,
    isOrgEventOwner,
    onlyOrgs
}