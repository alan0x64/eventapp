const fs = require('fs')
const path = require("path")
const event = require("../models/event")
const user = require("../models/user");
const org = require("../models/org")
const cert = require("../models/cert")
const PDF = require('pdf-lib').PDFDocument;
const { deleteImages, DateNowInMin, attendedInMin, RESPONSE } = require('../utils/shared_funs')
require("express")

function eventImages(req, eventx = {}) {
    const eventBackgroundPic = {
        fileName: req.eventPic,
        url: `${process.env.HOST}:${process.env.PORT}/uploads/events/${req.eventPic}`
    }
    const sig = {
        fileName: req.sig,
        url: `${process.env.HOST}:${process.env.PORT}/uploads/sigs/${req.sig}`
    }

    if (Object.keys(eventx).length == 0) { return { eventBackgroundPic, sig, } }

    const imagesToDelete = [
        path.join(`${__dirname}/..`, `/images/events/${eventx.eventBackgroundPic.fileName}`),
        path.join(`${__dirname}/..`, `/public/sigs/${eventx.sig.fileName}`)
    ]

    return { eventBackgroundPic, sig, imagesToDelete }
}

module.exports.createEvent = async (req, res) => {
    let orgId = req.logedinOrg.id

    if (!req.logedinOrg) return RESPONSE(res, 200, "No Org")

    let eventx = await new event({
        eventBackgroundPic: eventImages(req).eventBackgroundPic,
        sig: eventImages(req).sig,
        orgId: orgId,
        ...req.body.eventdata,
    }).save()

    await org.findByIdAndUpdate(orgId, {
        "$push": { orgEvents: eventx._id }
    })

    RESPONSE(res, 200, "Event Created")
}

module.exports.updateEvent = async (req, res) => {
    let orgId = req.logedinOrg.id
    await event.findByIdAndUpdate(req.params.eventId,
        {
            eventBackgroundPic: eventImages(req).eventBackgroundPic,
            sig: eventImages(req).sig,
            orgId: orgId,
            ...req.body.eventdata,
        })

    deleteImages(eventImages(req).imagesToDelete)
    RESPONSE(res, 200, "Event Updated")
}

module.exports.deleteEvent = async (req, res) => {
    let eventId = req.params.eventId
    this.deleteSingleEvent(eventId)
    RESPONSE(res, 200, "Event Deleted")
}


module.exports.getEvent = async (req, res) => {
    let eventx = await event.findById(req.params.eventId)
    if (eventx.length == 0) return RESPONSE(res, 400, "Event Does Not Exist")
    RESPONSE(res, 200, eventx)
}

module.exports.getEvents = async (req, res) => {
    RESPONSE(res, 200, await event.find({}))
}

module.exports.getEventOwner = async (req, res) => {
    let eventx = await event.findById(req.params.eventId)
    let orgx = await org.findById(eventx.orgId)
    if (orgx.length == 0) return RESPONSE(res, 200, "Org Does Not Exist")
    RESPONSE(res, 200, orgx)
}

module.exports.getEventMembers = async (req, res) => {
    let eventx = await event.findById(req.params.eventId).populate('eventMembers')
    RESPONSE(res, 200, eventx.eventMembers)
}

module.exports.getBlockedMembers = async (req, res) => {
    RESPONSE(res, 200, await event.findById(req.params.eventId).populate('blackListed'))
}

module.exports.checkIn = async (req, res) => {
    //Check IF user is blocoked
    let eventId = req.params.eventId
    let userId = req.logedinUser.id

    let eventx = await event.findById(eventId)
    let userx = await user.findById(userId)

    if (eventx.blackListed.includes(userId)) return RESPONSE(res, 400, "User Is Blocked")
    if (eventx.eventMembers.includes(userId) == false && userx.joinedEvents.includes(userId) == false)
        return RESPONSE(res, 400, "User Must Join The Event First")

    await cert.findOneAndDelete({
        'userId': userId,
        'orgId': eventx.orgId,
        'eventId': eventx._id
    })

    let newCertName = Date.now() + '.pdf'

    await new cert({
        userId: userId,
        eventId: eventx._id,
        orgId: eventx.orgId,
        checkInTime: DateNowInMin(),
        cert: {
            fileName: newCertName,
            url: `${process.env.HOST}:${process.env.PORT}/uploads/certs/${newCertName}`,
        }
    }).save()

    await eventx.updateOne({
        Attenders: (await cert.find({})).length
    })

    RESPONSE(res, 200, "User Checked In")
}

module.exports.checkOut = async (req, res) => {
    let eventId = req.params.eventId
    let userId = req.logedinUser.id
    let eventx = await event.findById(eventId)

    if (eventx.length==0) return RESPONSE(res,400,"Event Does Not Exist")
    if (eventx.blackListed.includes(userId)) return RESPONSE(res, 400, "User Is Blocked")

    let certx = await cert.findOne({
        userId: userId,
        eventId: eventx._id,
        orgId: eventx.orgId,
    })

    if (certx.length == 0) return RESPONSE(res, 400, "User Must Check In First")

    let checkoutTime = DateNowInMin()
    let attendedMins = attendedInMin(checkoutTime, certx.checkInTime)
    let allowCert = attendedMins >= eventx.minAttendanceTime


    if (allowCert) {
        await certx.updateOne({
            checkoutTime,
            attendedMins,
            allowCert: allowCert
        })

        await eventx.updateOne({
            "$inc": { 'Attended': 1 },
            "$push": { eventCerts: certx._id }
        })

    } 
    //should the cert be deleted if they re checkouted?
    // else {
    //     await certx.deleteOne()
    //     let certs = await cert.find({})
    //     await eventx.updateOne({
    //         Attenders: certs.length
    //     })
    // }

    RESPONSE(res, 200, "Checked Out")
}

module.exports.genCerts = async (req, res) => {

    let file = ""
    let eventId = req.params.eventId
    let eventx = await event.findById(eventId).populate('eventCerts')

    //set paths
    let certs = path.join(`${__dirname}/..`, `/public/certs`)
    let sigs = path.join(`${__dirname}/..`, `/public/sigs`)

    
    //read files
    if (eventx.eventType == 0) {
        file = fs.readFileSync(`${certs}/con.pdf`)
    } else {
        file = fs.readFileSync(`${certs}/sem.pdf`)
    }

    //check if user has 2 certs?
    eventx.eventCerts.forEach(async currentCert => {
        if(fs.existsSync(`${certs}/${currentCert.cert.fileName}`)) 
            fs.unlink(`${certs}/${currentCert.cert.fileName}`)

        if (
            currentCert.eventId.toString() == eventx._id.toString() &&
            currentCert.orgId.toString() == eventx.orgId.toString() &&
            currentCert.allowCert
        ) {
            
            //load pdf and get page 
            const pdf = await PDF.load(file)
            const page = pdf.getPages()[0]

            //load image 
            const imageBuffer = fs.readFileSync(`${sigs}/${eventx.sig.fileName}`)
            const pngImage = await pdf.embedPng(imageBuffer)

            let userx = await user.findById(currentCert.userId)
            let orgx = await org.findById(eventx.orgId)

            //set text size
            page.setFontSize(18)

            //draw text
            page.drawText(userx.fullName, { x: 270, y: 630 })
            page.drawText(eventx.title, { x: 257, y: 570 })
            page.drawText(new Date().toLocaleDateString(), { x: 257, y: 515 })

            const { width, height } = pngImage.scale(0.3);
            page.drawImage(pngImage, { x: 190, y: 410, width, height }, page)

            //writeback to file system
            fs.writeFileSync(`public/certs/${currentCert.cert.fileName}`, await pdf.save())
        }
    });

    RESPONSE(res,200, "Certs Generated")
}


module.exports.deleteSingleEvent = async function (id) {
    let eventx = await event.findById(id)
    let users = await user.find({
        'joinedEvents': eventx._id
    })

    users.forEach(async user => {
        await user.updateOne({
            $pull: { 'joinedEvents': eventx._id }
        })
    });

    await org.findByIdAndUpdate(eventx.orgId, {
        $pull: { 'orgEvents': eventx._id }
    })

    deleteImages(eventImages(req, eventx).imagesToDelete)
    await eventx.deleteOne()
    return
}