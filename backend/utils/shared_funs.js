const crypto = require("crypto");
const fs = require('fs')
const { ObjectId } = require('mongodb')
const chalk = require("chalk");
const event = require("../models/event");
const path = require("path");
const user = require("../models/user");
const PDF = require('pdf-lib').PDFDocument;


const userSearchFields = [
    'fullName',
    'email',
    'university',
    'faculty',
    'department',
    'scientific_title'
]

const eventSearchFields = [
    'title',
    'orgName',
    'email',
]




function RESPONSE(res, code, data) {
    let status

    if (code == 200) status = 'success'
    if (code == 400 || code == 500) status = 'error'
    if (code == 401) status = 'not authenticated'
    if (code == 403) status = 'forbidden'

    res.statusCode = code

    if (typeof data == "string") data = { "msg": data }

    res.send(
        {
            status: status,
            statusCode: code,
            timestamp: new Date().toISOString(),
            data:data,
        }
    )
    return
}

function deleteImages(images) {
    images.forEach(image => {
        console.log(`image:${image} Deleted`);
        fs.unlink(image, (err) => {
            if (err) {
                console.log(err);
                return
            }
        })
    });
}

function handleAsync(fun) {
    return (req, res, next) => {
        fun(req, res, next).catch(next)
    }
}
function catchFun(fun) {
    return async (req, res, next) => {
        try {
            await fun(req, res, next)
        } catch (error) {
            console.log(error)
            next(error)
        }
    }
}

function DateNowInMin() {
    return Math.floor(Date.now() / 60000)
}

function toMin(date) {
    return Date.parse(date)/60000 
}

function attendedInMin(checkin, checkout) {
    return checkin - checkout
}

function logError(err) {
    console.log('\n--------------------Error--------------------');
    console.log(`\n${err.stack}\n`);
    console.log('----------------------------------------\n');
}

function logx(str) {
    console.log('\n----------------------------------------');
    console.log(`${str}`);
    console.log('----------------------------------------\n');
}

function logger(req, res, next) {

    const start = Date.now()
    const time = new Date()
    
    const formattedDate = `${time.getFullYear()}-${(time.getMonth() + 1).toString().padStart(2, '0')}-${time.getDate().toString().padStart(2, '0')}`;
    const formattedTime = `${time.getHours().toString().padStart(2, '0')}:${time.getMinutes().toString().padStart(2, '0')}:${time.getSeconds().toString().padStart(2, '0')}`;
    const formattedDateTime = `${formattedDate} ${formattedTime}`;

url = req.url
    res.on('finish', () => {
        let x = (Date.now() - start);
        let color = 'white';
        let statusCode = res.statusCode
        if (statusCode >= 200 && statusCode < 300) {
            color = 'green';
        } else if (statusCode >= 300 && statusCode < 400) {
            color = 'yellow';
        } else if (statusCode >= 400) {
            color = 'red';
        }
        let ip = req.socket.remoteAddress || req.ip
        if (ip.substr(0, 7) === "::ffff:") {
            ip = ip.substr(7);
        }
        console.log(
            `${req.method} ${url} ${chalk[color](statusCode)} ${x} ms ${ip} ${formattedDateTime}`
        );
    })
    next()
}

const validateObjectID = (req, res, next) => {
    const { userId, eventId } = req.body
    if (userId == null || eventId == null) return RESPONSE(res, 400, "Missing IDs")
    if (!ObjectId.isValid(userId) || !ObjectId.isValid(eventId)) return RESPONSE(res, 400, "Invalid IDs")
    next()
}

async function searchFor(model, list, fieldName, fieldValue,populateField,status,type) {

    populateField=populateField==null?"":populateField
    status=status==null?-1:status
    type=type==null?-1:type

    let searchBody = {
        $and: [
            list != null ? { _id: { $in: list } } : {},
            status != -1 ? {status: status } : {},
            type != -1 ? {eventType: type } : {},
            { [fieldName]: { $regex: new RegExp(`${fieldValue}`, 'i') } },
        ],
    }
    return await model.find(searchBody).populate(populateField)
}

function getUsersInCerts(certs) {
    let usersList = []
    certs.forEach(cert => {
        usersList.push(cert.userId)
    });
    return usersList
}




async function genCerts(req,res,sendRes) {
    if (sendRes == null) sendRes = 1

    try {
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
            if (fs.existsSync(`${certs}/${currentCert.cert.fileName}`))
                fs.unlink(`${certs}/${currentCert.cert.fileName}`, () => { })

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

                let userx = await user.findById(currentCert.userId)
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
                fs.writeFileSync(`public/certs/${currentCert.cert.fileName}`, await pdf.save())
            }
        });
        if (sendRes) RESPONSE(res, 200, "Certs Generated")
    } catch (error) {
        logError(error)
    }
}


module.exports = {
    RESPONSE,
    validateObjectID,
    deleteImages,
    handleAsync,
    DateNowInMin,
    attendedInMin,
    logError,
    catchFun,
    logx,
    logger,
    userSearchFields,
    eventSearchFields,
    searchFor,
    getUsersInCerts,
    toMin,
    genCerts,
}


