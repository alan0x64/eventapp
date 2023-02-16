const path = require("path")
const express = require("express")()
const org = require("../models/org")
const jwt = require("jsonwebtoken")
const event = require("../models/event")
const user = require("../models/user")
const cert = require("../models/cert")
const token_collection = require("../models/token")
const { hashSync, compareSync } = require('bcrypt')
const { RESPONSE, deleteImages, logx } = require('../utils/shared_funs')
const { deleteSingleEvent } = require("./event")

function orgImages(req, orgx = {}) {
    const orgPic = {
        fileName: req.orgPic,
        url: `${process.env.HOST}:${process.env.PORT}/uploads/orgs/org_images/${req.orgPic}`
    }

    const orgBackgroundPic = {
        fileName: req.orgBackgroundPic,
        url: `${process.env.HOST}:${process.env.PORT}/uploads/orgs/background_images/${req.orgBackgroundPic}`
    }

    if (Object.keys(orgx).length == 0) { return { orgPic, orgBackgroundPic } }

    const imagesToDelete = [
        path.join(`${__dirname}/..`, `/images/orgs/org_images/${orgx.orgPic.fileName}`),
        path.join(`${__dirname}/..`, `/images/orgs/background_images/${orgx.orgBackgroundPic.fileName}`)
    ]

    return { orgPic, orgBackgroundPic, imagesToDelete }

}
module.exports.createOrg = async (req, res) => {
    logx(req.body.password)
    await new org({
        ...req.body,
        orgPic: orgImages(req).orgPic,
        orgBackgroundPic: orgImages(req).orgBackgroundPic,
        password: hashSync(req.body.password, 12)
    }).save()

    RESPONSE(res, 200, "Organization Created")
}

module.exports.updateOrg = async (req, res) => {
    let orgId = req.logedinOrg.id
    let orgx = await org.findById(orgId)
    let orgPic
    let orgBackgroundPic

    if (!req.orgBackgroundPic) {
        deleteImages([orgImages(req, orgx).imagesToDelete[0]])
        orgPic = orgImages(req).orgPic

    } else if (!req.orgPic) {
        deleteImages([orgImages(req, orgx).imagesToDelete[1]])
        orgBackgroundPic = orgImages(req).orgBackgroundPic

    } else {
        deleteImages(orgImages(req, orgx).imagesToDelete)
        orgPic = orgImages(req).orgPic
        orgBackgroundPic = orgImages(req).orgBackgroundPic
    }

    await org.findByIdAndUpdate(orgId, {
        ...req.body,
        orgPic,
        orgBackgroundPic
    })

    RESPONSE(res, 200, "Organization Updated")
}

module.exports.updateOrgx = async (req, res) => {
    let orgId = req.logedinOrg.id
    await org.findByIdAndUpdate(orgId, { ...req.body })
    RESPONSE(res, 200, "Updated Organization")
}

module.exports.deleteOrg = async (req, res) => {
    let orgId = req.logedinOrg.id
    let orgx = await org.findByIdAndDelete(orgId)

    orgx.orgEvents.forEach(eventId => {
        deleteSingleEvent(eventId)
    });

    await token_collection.deleteMany({ 'orgId': orgId })
    deleteImages(orgImages(req, orgx).imagesToDelete)
    RESPONSE(res, 200, "Organization Deleted")
}

module.exports.updatePassword = async (req, res) => {
    let orgId = req.logedinOrg.id
    let orgx = await org.findById(orgId)

    logx(req.body.cuurentPassword)
    logx(req.body.newPassword)

    if (!compareSync(req.body.cuurentPassword, orgx.password)) 
    return RESPONSE(res, 400, "Incorrect Current Password")

    await orgx.updateOne({
        password: hashSync(req.body.newPassword, 12)
    })
    
    RESPONSE(res, 200, "Password Updated")
}


module.exports.getOrg = async (req, res) => {
    let orgx = await org.findOne({ '_id': req.params.id })
    if (orgx.length == 0) return RESPONSE(res, 400, "Org Not Found")
    RESPONSE(res, 200, orgx)
}

module.exports.getLogedInOrg = async (req, res) => {
    RESPONSE(res, 200, await org.findOne({ '_id': req.logedinOrg.id }))
}


module.exports.login = async (req, res) => {

    let loginOrg = await org.findOne({ 'email': req.body.email })

    if (!loginOrg) {
        RESPONSE(res, 400, "Organization Not Found")
        return
    }
    if (!compareSync(req.body.password, loginOrg.password)) return RESPONSE(res, 400, "Incorrect Email or Password")

    let AT = jwt.sign({
        id: loginOrg._id
    }, process.env.ACCESS_TOKEN, { expiresIn: "15m", algorithm: "HS512" })

    let RT = jwt.sign({
        id: loginOrg._id,
        email: loginOrg.email,
        imei: "NULL",
    }, process.env.REFRESH_TOKEN, { expiresIn: "1w", algorithm: "HS512" })


    await new token_collection({
        orgId: loginOrg._id,
        imei: "NULL",
        RT: RT,
    }).save()


    RESPONSE(res, 200, {
        AT: "Bearer " + AT,
        RT: "Bearer " + RT,
    })
}


module.exports.logout = async (req, res) => {
    let data = await token_collection.find({
        'orgId': req.logedinOrg.id,
        'RT': req.RT
    })

    if (data.length == 0) return RESPONSE(res, 400, "Not Logedin")


    await token_collection.findOneAndDelete({
        'orgId': req.logedinOrg.id,
        'RT': req.RT
    })

    RESPONSE(res, 200, "Loged Out")
}

module.exports.BLUser = async (req, res) => {
    let userId = req.params.userId
    let eventId = req.params.eventId

    let eventx = await event.findById(eventId)
    let userx = await user.findById(userId)

    if (eventx.blackListed.includes(userId)) return RESPONSE(res, 200, 'User Is Already Blcoked')

    if (!userx.joinedEvents.includes(eventId)) return RESPONSE(res, 200, 'User Did Join Event')

    await user.findByIdAndUpdate(userId, {
        "$pull": { 'joinedEvents': eventId }
    })

    let certx = await cert.findOneAndDelete({
        userId: userx._id,
        eventId: eventx._id,
        orgId: eventx.orgId,
    })

    let certs = await cert.find({ 'eventId': eventx._id, 'orgId': eventx.orgId })

    //check if de attenders or attedeeded
    if (certx.allowCert) {
        await eventx.updateOne({
            "$push": { 'blackListed': userx._id },
            "$pull": { 'eventMembers': userx._id },
            "$pull": { eventCerts: certx._id },
            "$inc": { Attended: -1 },
            Attenders: certs.length,
        })
    } else {
        await eventx.updateOne({
            "$push": { 'blackListed': userx._id },
            "$pull": { 'eventMembers': userx._id },
            Attenders: certs.length,
        })
    }

    RESPONSE(res, 200, "User Blocked")
}

module.exports.UBLUser = async (req, res) => {
    let userId = req.params.userId
    let eventId = req.params.eventId
    let eventx = await event.findById(eventId)

    if (!eventx.blackListed.includes(userId)) return RESPONSE(res, 200, "User Is Not Blocked")

    await event.findByIdAndUpdate(eventId, {
        "$pull": { 'blackListed': userId }
    })

    RESPONSE(res, 200, "Unblocked User")
}

module.exports.getOrgEvents = async (req, res) => {
    let orgId = req.logedinOrg.id
    let orgx = await org.findById(orgId).populate('orgEvents')
    if (orgx.length == 0) return RESPONSE(res, 400, "Org Not Found")
    RESPONSE(res, 200, {"events":orgx.orgEvents})
}

module.exports.getParticularOrgEvents = async (req, res) => {
    let orgId = req.params.orgId
    let orgx = await org.findById(orgId).populate('orgEvents')
    if (orgx.length == 0) return RESPONSE(res, 400, "Org Not Found")
    RESPONSE(res, 200, {"events":orgx.orgEvents})
}