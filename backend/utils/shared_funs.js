const crypto = require("crypto");
const fs = require('fs')
const {ObjectId}=require('mongodb')
const chalk=require("chalk")

function RESPONSE(res, code, data) {
    let status
    
    if (code == 200) status = 'success'
    if (code == 400 || code == 500) status = 'error'
    if (code == 401) status = 'not authenticated'
    if (code == 403) status = 'forbidden'

    res.statusCode = code

    if (typeof data == "string") data={"msg":data}
    
    res.send(
        {
            status: status,
            statusCode: code,
            timestamp: new Date().toISOString(),
            data:data ,
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
 function catchFun(fun)  {
    return async (req,res,next)=>{
        try {
            await fun(req,res,next)
        } catch (error) {
            logError(error)
            next(error)
        }
    }
} 

function DateNowInMin() {
    return Math.floor(Date.now() / 60000)
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

function logger(req,res,next) {

    const start=Date.now()
    url=req.url
    res.on('finish',()=>{
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
        let ip = req.socket.remoteAddress||req.ip 
        if (ip.substr(0, 7) === "::ffff:") {
            ip = ip.substr(7);
        }
        console.log(
            `${req.method} ${url} ${chalk[color](statusCode)} ${x} ms ${ip}`
        );
    })
    next()
}

const validateObjectID=(req,res,next)=>{
    const {userId,eventId}=req.body
    if (userId==null||eventId==null) return RESPONSE(res,400,"Missing IDs")
    if (!ObjectId.isValid(userId) || !ObjectId.isValid(eventId)) return RESPONSE(res,400,"Invalid IDs")
    next()
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
    logger
}
