const path = require("path")
const express = require("express")()
const jwt = require("jsonwebtoken")
const user = require("../models/user")
const event = require("../models/event")
const cert = require("../models/cert")
const token_collection = require("../models/token")
const { hashSync, compareSync } = require('bcrypt')
const { RESPONSE, deleteImages } = require('../utils/shared_funs')

function userImages(req, userx = {},cert={}) {
    const profilePic = {
        fileName: req.profilePic,
        url: `${process.env.HOST}:${process.env.PORT}/uploads/users/${req.profilePic}`
    }

    if (Object.keys(userx).length == 0) { return { profilePic } }

    const imagesToDelete = [
        path.join(`${__dirname}/..`, `/images/users/${userx.profilePic.fileName}`)
    ]
    
    if (Object.keys(cert).length == 0)  return { profilePic, imagesToDelete }
    
    const certToDelete=[
        path.join(`${__dirname}/..`, `/public/certs/${cert.fileName}`)
    ]

    return { profilePic, imagesToDelete ,certToDelete}
}


module.exports.createUser = async (req, res) => {
    await new user({
        ...req.body.userdata,
        profilePic: userImages(req).profilePic,
        password: hashSync(req.body.userdata.password, 12)
    }).save()
    RESPONSE(res, 200, "User Created")
}



module.exports.updateUser = async (req, res) => {
    let userx = await user.findByIdAndUpdate(req.logedinUser.id, {
        ...req.body.userdata,
        profilePic: userImages(req).profilePic,
        password: hashSync(req.body.userdata.password, 12)
    })
    deleteImages(userImages(req, userx).imagesToDelete)
    RESPONSE(res,200,"User Updated")
}


module.exports.deleteUser = async (req, res) => {
    let userId = req.logedinUser.id
    let userx = await user.findByIdAndDelete(userId)

    if  (userx.length==0) return RESPONSE(res,400,"User Does Not Exist")


    // Remove User From all events 
    let events=await event.find({
        $or:[
            {'eventMembers':userId},
            {'blackListed':userId},
        ]
    })

    events.forEach(async event => {
        let certx=await (cert.findOne({'userId':userId,'eventId':event._id,'orgId':event.orgId})).deleteOne()
        let certs=await cert.find({'eventId':event._id,'orgId':event.orgId})
        if (certx.allowCert) {
            await event.updateOne({
                $inc:{Attended:-1},
                $inc:{Attenders:certs.length},
                $pull:{'eventMembers':userId},
                $pull:{'eventCerts':userId},
                $pull:{'blackListed':userId},
            })
        }else{
            await event.updateOne({
                $inc:{Attenders:certs.length},
                $pull:{'eventMembers':userId},
                $pull:{'eventCerts':userId},
                $pull:{'blackListed':userId},
            })
        }
        deleteImages(userImages(req,user,certx).certToDelete)
     });


    deleteImages(userImages(req, userx).imagesToDelete)
    await token_collection.deleteMany({ 'userId': userId })
    RESPONSE(res,200,"User Deleted")
}

module.exports.getUser = async (req, res) => {
    let data = await user.findOne({ '_id': req.params.id })
    if (data.length == 0) return RESPONSE(res, 400, { error: 'User Not Found' })
    RESPONSE(res, 200, data)
}

module.exports.getLogedInUser = async (req, res) => {
    RESPONSE(res, 200, await user.findOne({ '_id': req.logedinUser.id }))
}

module.exports.login = async (req, res) => {

    let loginUser = await user.findOne({ 'email': req.body.userdata.email })

    if (!loginUser) return RESPONSE(res,400,"User Not Found")
    if (!compareSync(req.body.userdata.password, loginUser.password)) return RESPONSE(res,400,"Incorrect Email or Password")


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

    if (data.length == 0)  return RESPONSE(res, 400, "Not Logedin")
    
    await token_collection.deleteMany({
        'userId': req.logedinUser.id,
        'RT': req.RT
    })

    RESPONSE(res, 200, "Loged Out")
}

module.exports.AddUserToEvent = async (req, res) => {

    let userId = req.logedinUser.id
    let eventId = req.params.eventId
    let eventx = await event.findById(eventId)

    if (eventx.eventMembers.length >= eventx.sets) return RESPONSE(res,200,"No Sets Left")
    if (eventx.blackListed.includes(userId)) return RESPONSE(res,200,"User Is Blocked")
    if (eventx.eventMembers.includes(userId)) return RESPONSE(res,200,"User Already Joined Event")

    
    await event.findOneAndUpdate(eventId, {
        "$push": { eventMembers: userId },
    })

    await user.findOneAndUpdate(userId, {
        "$push": { joinedEvents: eventId }
    })

    RESPONSE(res,200,"User Added To Event")
}

module.exports.RemoveUserFromEvent = async (req, res) => {
    let userId = req.logedinUser.id
    let eventId = req.params.eventId

    let eventx = await event.findById(eventId)
    let userx = await user.findById(userId)

    if (eventx.eventMembers.includes(userId) && userx.joinedEvents.includes(userId)) return RESPONSE(res,200,"User Is Not Event Member")

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

    RESPONSE(res, 200, "User Removed To Event")
}

module.exports.getCertificate = async (req, res) => {
    let userId = req.logedinUser._id
    let eventId = req.params.eventId

    let eventx = await event.findById(eventId).populate('eventCerts')
    
    if (eventx.length == 0) return RESPONSE(res, 400, { 'error': "Event Not Found" })

    eventx.eventCerts.forEach(cert => {
        if (cert.userId.toString() == userId.toString()) {
            res.download(`public/certs/${cert.cert.fileName}`, `${eventx.title}_certificate`)
        }
    });
}


module.exports.getJoinedEvents=async (req,res)=>{
    return RESPONSE(res,200,(await user.findById(req.logedinUser._id).populate('joinedEvents')).joinedEvents)
}