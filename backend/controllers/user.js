const path = require("path")
const express = require("express")()
const jwt = require("jsonwebtoken")
const user = require("../models/user")
const event = require("../models/event")
const cert = require("../models/cert")
const token_collection = require("../models/token")
const { hashSync, compareSync } = require('bcrypt')
const { RESPONSE, deleteImages, getUsersInCerts, searchFor, userSearchFields, logx, genCerts, getCertAttendance, checkFileExists } = require('../utils/shared_funs')

function userImages(req, userx = {}, cert = {}) {
    const profilePic = {
        fileName: req.profilePic,
        url: `${process.env.HOST}:${process.env.PORT}/uploads/users/${req.profilePic}`
    }

    if (Object.keys(userx).length == 0) { return { profilePic } }

    const imagesToDelete = [
        path.join(`${__dirname}/..`, `/images/users/${userx.profilePic.fileName}`)
    ]

    if (Object.keys(cert).length == 0) return { profilePic, imagesToDelete }

    const certToDelete = [
        path.join(`${__dirname}/..`, `/public/certs/${cert.fileName}`)
    ]

    return { profilePic, imagesToDelete, certToDelete }
}


module.exports.createUser = async (req, res) => {
    await new user({
        ...req.body,
        profilePic: userImages(req).profilePic,
        password: hashSync(req.body.password, 12)
    }).save()
    RESPONSE(res, 200, "User Created")
}



module.exports.updateUser = async (req, res) => {
    let body={...req.body,}
    let userx=await user.findById(req.logedinUser.id)


    if (req.method=='PUT') {
        body.profilePic=userImages(req).profilePic,
        deleteImages(userImages(req, userx).imagesToDelete)
    }

    await userx.updateOne(body)
    RESPONSE(res, 200, "Changes Saved")
}

module.exports.updatePassword = async (req, res) => {
    let userId = req.logedinUser.id
    let userx = await user.findById(userId)

    logx(req.body)
    if (!compareSync(req.body.password, userx.password))
        return RESPONSE(res, 400, "Incorrect Current Password")

    await userx.updateOne({
        password: hashSync(req.body.newPassword, 12)
    })

    RESPONSE(res, 200, "Password Updated")
}


module.exports.deleteUser = async (req, res) => {
    let userId = req.logedinUser.id
    let userx = await user.findByIdAndDelete(userId)

    if (userx == 0) return RESPONSE(res, 400, "User Does Not Exist")


    // Remove User From all events 
    let events = await event.find({
        $or: [
            { 'eventMembers': userId },
            { 'blackListed': userId },
        ]
    })

    for (const event of events) {
        let certx = await (cert.findOne({ 'userId': userId, 'eventId': event._id, 'orgId': event.orgId })).deleteOne()

        attenders=(await getCertAttendance(event._id)).length

        if (certx.allowCert) {
            await event.updateOne({
                Attended: (await getCertAttendance(event._id,1)).length,
                Attenders: attenders,
                $pull: { 'eventMembers': userId },
                $pull: { 'eventCerts': certx._id },
                $pull: { 'blackListed': userId },
            })
        } else {
            await event.updateOne({
                Attenders:attenders,
                $pull: { 'eventMembers': userId },
                $pull: { 'eventCerts': certx._id },
                $pull: { 'blackListed': userId },
            })
        }
        deleteImages(userImages(req, user, certx).certToDelete)
    }

    deleteImages(userImages(req, userx).imagesToDelete)
    await token_collection.deleteMany({ 'userId': userId })
    RESPONSE(res, 200, "User Deleted")
}

module.exports.getUser = async (req, res) => {
    let data = await user.findOne({ '_id': req.params.id })
    if (data.length == 0) return RESPONSE(res, 400, { error: 'User Not Found' })
    RESPONSE(res, 200, data)
}

module.exports.getLogedInUser = async (req, res) => {
    let userx = await user.findById(req.logedinUser.id)
    RESPONSE(res, 200, userx)
}

module.exports.login = async (req, res) => {

    let loginUser = await user.findOne({ 'email': req.body.email })

    if (!loginUser) return RESPONSE(res, 400, "User Not Found")
    if (!compareSync(req.body.password, loginUser.password)) return RESPONSE(res, 400, "Incorrect Email or Password")


    const AT = jwt.sign({
        id: loginUser._id
    }, process.env.ACCESS_TOKEN, { expiresIn: "30m", algorithm: "HS512" })

    const RT = jwt.sign({
        id: loginUser._id,
        email: loginUser.email,
        imei: "NULL"
    }, process.env.REFRESH_TOKEN, { expiresIn: "2w", algorithm: "HS512" })


    await new token_collection({
        userId: loginUser._id,
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
        'userId': req.logedinUser.id,
        'RT': req.RT
    })

    if (data.length == 0) return RESPONSE(res, 400, "Not Logedin")

    await token_collection.deleteMany({
        'userId': req.logedinUser.id,
        'RT': req.RT
    })

    RESPONSE(res, 200, "Loged Out")
}

module.exports.AddUserToEvent = async (req, res) => {

    let userId = req.logedinUser.id
    let eventId = req.params.eventId
    let userx = await user.findById(userId)
    let eventx = await event.findById(eventId)
    let check = req.body.check

    let member = eventx.eventMembers.includes(userId)
    let joined = userx.joinedEvents.includes(eventId)


    if (check == 1) {
        if (member && joined) {
            return RESPONSE(res, 200, {'msg':true})
        }
        return RESPONSE(res, 200, {'msg':false})
    }


    if (eventx.blackListed.includes(userId)) return RESPONSE(res, 400, "You Are Blocked From Registering")
    if (member && joined) return RESPONSE(res, 400, "Already Registred")


    await eventx.updateOne({
        "$push": { eventMembers: userId },
    })

    await userx.updateOne({
        "$push": { joinedEvents: eventId }
    })

    RESPONSE(res, 200, "Registred")
}

module.exports.RemoveUserFromEvent = async (req, res) => {
    let userId = req.logedinUser.id
    let eventId = req.params.eventId

    let eventx = await event.findById(eventId)
    let userx = await user.findById(userId)

    if (!eventx.eventMembers.includes(userId) && !userx.joinedEvents.includes(userId)) return RESPONSE(res, 400, "You Are Not Registered")

    await eventx.updateOne({
        "$pull": { eventMembers: userId },
    })

    await userx.updateOne({
        "$pull": { joinedEvents: eventId }
    })

    await cert.findOneAndDelete({
        userId: userx._id,
        eventId: eventx._id,
        orgId: eventx.orgId,
    })

    RESPONSE(res, 200, "Unregistred")
}


module.exports.getCertificate = async (req, res) => {
    let userId = req.logedinUser._id
    let eventId = req.params.eventId
    let eventx = await event.findById(eventId)

    if (eventx == null) return RESPONSE(res, 400, { 'msg': "Event Not Found" })

    let certx = await cert.findOne({
        userId: userId,
        eventId: eventId,
    })

    if (certx ==null) return RESPONSE(res, 200, { 'msg': 0 })        

    let syspath=path.join(`${__dirname}/..`, `/public/certs`)+'/'+certx.cert.fileName

    if (checkFileExists(syspath)){
        return  RESPONSE(res,200,certx.cert.url)
    }


    RESPONSE(res, 200, { 'msg': 0 })
}

module.exports.getJoinedEvents = async (req, res) => {
    return RESPONSE(res, 200, { 'events': (await user.findById(req.logedinUser._id).populate('joinedEvents')).joinedEvents })
}

module.exports.search = async (req, res) => {

    let { eventId, fieldValue, lnum, fnum } = req.body
    let eventx = await event.findById(eventId).populate("eventCerts")

    let lists = [
        getUsersInCerts(await getCertAttendance(eventId)),
        eventx.eventMembers,
        eventx.blackListed,
        getUsersInCerts(await getCertAttendance(eventId,0))
    ]
    
    let userx = await searchFor(user, lists[lnum], userSearchFields[fnum], fieldValue,null)
    return RESPONSE(res, 200, { 'members': userx })
}

