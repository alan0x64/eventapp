const fs = require('fs')
const path = require("path")
const event = require("../models/event")
const user = require("../models/user");
const org = require("../models/org")
const orgCon = require('../controllers/org')
const cert = require("../models/cert")
const PDF = require('pdf-lib').PDFDocument;
const { deleteImages, DateNowInMin, attendedInMin, RESPONSE, logx, logError, toMin, genCerts, userSearchFields, eventSearchFields, searchFor, filterBody, getCertAttendance } = require('../utils/shared_funs');
const autoEvent = require('../utils/auto');
const { parseLatLon, isInsideCircle, } = require('./../utils/location')

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

    if (!req.logedinOrg) return RESPONSE(res, 400, "No Org")

    let eventx = await new event({
        ...req.body,
        eventBackgroundPic: eventImages(req).eventBackgroundPic,
        sig: eventImages(req).sig,
        orgId: orgId,
        status: 0
    }).save()

    await org.findByIdAndUpdate(orgId, {
        "$push": { orgEvents: eventx._id }
    })

    RESPONSE(res, 200, "Event Created")
}

module.exports.updateEvent = async (req, res) => {
    let orgId = req.logedinOrg.id
    let eventx = await event.findById(req.params.eventId)
    let eventimage = eventImages(req, eventx)
    let body = { ...req.body, orgId: orgId, }

    if (req.method == "PUT") {
        if (req.eventPic) {
            body.eventBackgroundPic = eventimage.eventBackgroundPic,
                deleteImages([eventimage.imagesToDelete[0]])

        } else {
            body.sig = eventimage.sig,
                deleteImages([eventimage.imagesToDelete[1]])
        }
    }

    await eventx.updateOne(body)
    RESPONSE(res, 200, "Event Updated")
}

module.exports.deleteEvent = async (req, res) => {
    let eventId = req.params.eventId
    this.deleteSingleEvent(req, eventId)
    RESPONSE(res, 200, "Event Deleted")
}


module.exports.getEvent = async (req, res) => {
    let eventx = await event.findById(req.params.eventId)
    if (eventx.length == 0 || eventx == null) return RESPONSE(res, 400, "Event Does Not Exist")
    await autoEvent(req, res, req.params.eventId || req.body.eventId)
    RESPONSE(res, 200, eventx)
}

module.exports.getEvents = async (req, res) => {

    let type = req.query.type
    let status = req.query.status
    let eventsNearUser = []
    let events = await event.find({
        $and: [
            status != -1 ? { status: status } : {},
            type != -1 ? { eventType: type } : {},
        ],
    }
    )

    for (const event of events) {
        await autoEvent(req, res, event.id)
        if (isInsideCircle(req, event.location)) eventsNearUser.push(event)
    }

    RESPONSE(res, 200, { "events": eventsNearUser })
}

module.exports.getEventOwner = async (req, res) => {
    let eventx = await event.findById(req.params.eventId)
    let orgx = await org.findById(eventx.orgId)
    if (orgx.length == 0) return RESPONSE(res, 200, "Org Does Not Exist")
    RESPONSE(res, 200, orgx)
}


module.exports.getEventCerts = async (req, res) => {
    let eventx = await event.findById(req.params.eventId).populate({
        path: 'eventCerts',
        populate: {
            'path': 'userId'
        }
    })
    RESPONSE(res, 200, { 'certs': eventx.eventCerts })
}

module.exports.getEventMembers = async (req, res) => {
    let eventx = await event.findById(req.params.eventId).populate('eventMembers')
    RESPONSE(res, 200, { "members": eventx.eventMembers })
}

module.exports.getBlockedMembers = async (req, res) => {
    let eventx = await event.findById(req.params.eventId).populate('blackListed')
    RESPONSE(res, 200, { "members": eventx.blackListed })
}

module.exports.checkIn = async (req, res) => {

    let eventId = req.body.eventId
    let userId = req.body.userId

    let eventx = await event.findById(eventId)
    let userx = await user.findById(userId)

    if (eventx.blackListed.includes(userId)) return RESPONSE(res, 400, "User Is Blocked")
    if (eventx.eventMembers.includes(userId) == false && userx.joinedEvents.includes(userId) == false)
        return RESPONSE(res, 400, "User Must Register First")
    if (eventx.Attenders >= eventx.seats) return RESPONSE(res, 200, "No Seats Left")

    await cert.findOneAndDelete({
        'userId': userId,
        'orgId': eventx.orgId,
        'eventId': eventx._id
    })

    let newCertName = Date.now() + '.pdf'

    let certx = await new cert({
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
        Attenders: (await getCertAttendance(eventx._id)).length,
        "$push": { 'eventCerts': certx._id }
    })

    RESPONSE(res, 200, `Checked In ${userx.fullName} `)
}

module.exports.checkOut = async (req, res) => {
    let eventId = req.body.eventId
    let userId = req.body.userId
    let eventx = await event.findById(eventId)
    let userx = await user.findById(userId)
    let checkOutTime = DateNowInMin()

    if (eventx == null) return RESPONSE(res, 400, "CheckOut Failed\nEvent Does Not Exist")
    if (eventx.blackListed.includes(userId)) return RESPONSE(res, 400, "CheckOut Failed\nUser Is Blocked")

    let certx = await cert.findOne({
        userId: userId,
        eventId: eventx._id,
        orgId: eventx.orgId,
    })

    if (!certx || certx.length == 0 || checkOutTime < certx.checkInTime) return RESPONSE(res, 400, "CheckOut Failed \nUser Must Check In First")

    let attendedMins = attendedInMin(checkOutTime, certx.checkInTime)
    let allowCert = attendedMins >= eventx.minAttendanceTime
    let allowed="Forbidden"
    let fullName = userx.fullName;
let capitalizedFullName = fullName.charAt(0).toUpperCase() + fullName.slice(1);

    let updatebody = {
        'checkOutTime': checkOutTime,
        'attendedMins': attendedMins,
        'allowCert': allowCert
    }

    await cert.updateOne(updatebody)

    await eventx.updateOne({
        'Attended': (await getCertAttendance(eventId, 1)).length,
    })

    if (allowCert) {
        allowed='Eligible'
    }

    RESPONSE(res, 200, ` CheckOut Successful\n User : ${capitalizedFullName} \n Details recorded : \n\n Certification : ${allowed} \n Attended : ${attendedMins} Minutes`)
}

module.exports.makeCerts = async (req, res) => {
    await genCerts(req, res)
}


module.exports.genCert = async (req, res) => {
    try {

        let file = ""
        let eventId = req.params.eventId

        let userId = req.params.userId
        let userx = await user.findById(userId)

        let eventx = await event.findById(eventId)
        let orgx = await org.findById(eventx.orgId)


        let certx = await cert.findOne({
            userId: userId,
            eventId: eventId,
            orgId: eventx.orgId
        })

        //set paths
        let certs = path.join(`${__dirname}/..`, `/public/certs`)
        let sigs = path.join(`${__dirname}/..`, `/public/sigs`)


        if (certx == null) {
            let newCertName = Date.now() + '.pdf'
            certx = await new cert({
                userId: userId,
                eventId: eventx._id,
                orgId: eventx.orgId,
                checkInTime: 0,
                checkOutTime: 0,
                allowCert: true,
                attendedMins: 0,
                cert: {
                    fileName: newCertName,
                    url: `${process.env.HOST}:${process.env.PORT}/uploads/certs/${newCertName}`,
                }
            }).save()

            await eventx.updateOne({
                $push: { 'eventCerts': certx._id }
            })
        }

        //read files
        if (eventx.eventType == 0) {
            file = fs.readFileSync(`${certs}/con.pdf`)
        } else {
            file = fs.readFileSync(`${certs}/sem.pdf`)
        }

        //check if user has 2 certs
        if (fs.existsSync(`${certs}/${certx.cert.fileName}`))
            fs.unlink(`${certs}/${certx.cert.fileName}`, () => { })


        //load pdf and get page 
        const pdf = await PDF.load(file)
        const page = pdf.getPages()[0]

        //load image 
        const imageBuffer = fs.readFileSync(`${sigs}/${eventx.sig.fileName}`)
        let image

        if (eventx.sig.fileName.substring(eventx.sig.fileName.indexOf('.') + 1) == 'jpg') {
            image = await pdf.embedJpg(imageBuffer)
        } else if (eventx.sig.fileName.substring(eventx.sig.fileName.indexOf('.') + 1) == 'png') {
            image = await pdf.embedPng(imageBuffer)
        }
        else {
            return RESPONSE(res, 400, "The signature file either lacks a PNG or JPG extension, or it has a different extension")
        }

        //set text size
        page.setFontSize(18)

        //draw text
        page.drawText(userx.fullName, { x: 270, y: 630 })
        page.drawText(eventx.title, { x: 257, y: 570 })
        page.drawText(new Date().toLocaleDateString(), { x: 257, y: 515 })

        const { width, height } = image.scale(0.3);
        page.drawImage(image, { x: 190, y: 410, width, height }, page)

        //writeback to file system
        fs.writeFileSync(`public/certs/${certx.cert.fileName}`, await pdf.save())

        RESPONSE(res, 200, "Cert Generated For The Current User")
    } catch (error) {
        console.log(error);
        RESPONSE(res, 500, "OPPS")

    }
}



module.exports.deleteSingleEvent = async function (req, id) {
    let eventx = await event.findById(id)
    let users = await user.find({
        'joinedEvents': eventx._id
    })

    for (const user of users) {
        await user.updateOne({
            $pull: { 'joinedEvents': eventx._id }
        })
    }

    await org.findByIdAndUpdate(eventx.orgId, {
        $pull: { 'orgEvents': eventx._id }
    })

    deleteImages(eventImages(req, eventx).imagesToDelete)
    await eventx.deleteOne()
    return
}


module.exports.getAttenders = async (req, res) => {
    let attenders = []
    let eventId = req.params.eventId
    let eventx = await event.findById(eventId).populate(
        {
            path: 'eventCerts',
            populate: {
                path: 'userId'
            }
        }
    )

    for (const cert of eventx.eventCerts) {
        if (cert.checkInTime != 0) {
            attenders.push(cert.userId)
        }
    }

    return RESPONSE(res, 200, { 'members': attenders })
}

module.exports.getAttended = async (req, res) => {
    let attenders = []
    let eventId = req.params.eventId
    let eventx = await event.findById(eventId).populate(
        {
            path: 'eventCerts',
            populate: {
                path: 'userId'
            }
        }
    )

    for (const cert of eventx.eventCerts) {
        if (cert.checkInTime != 0 && cert.checkOutTime != 0) {
            attenders.push(cert.userId)
        }
    }

    return RESPONSE(res, 200, { 'members': attenders })
}



module.exports.removeUserFromEvent = async (req, res) => {
    return orgCon.BLUser(req, res, false)
}


module.exports.search = async (req, res) => {

    console.log(req.body);

    let { fieldValue, fnum } = req.body
    let model, fieldToPopulate
    let events = []
    let eventsNearUser = []
    let status = req.query.status
    let type = req.query.type

    if (fnum > 0) {
        model = org
        fieldToPopulate = 'orgEvents'
    } else {
        model = event
        fieldToPopulate = ''
    }


    let data = await searchFor(model, null, eventSearchFields[fnum], fieldValue, fieldToPopulate, status, type)


    if (fnum > 0) {
        for (const org of data) {
            org.orgEvents.forEach(event => {
                events.push(event)
            });
        }
    } else {
        events = data
    }

    for (const event of events) {
        if (isInsideCircle(req, event.location)) eventsNearUser.push(event)
    }


    return RESPONSE(res, 200, { 'events': eventsNearUser })
}

