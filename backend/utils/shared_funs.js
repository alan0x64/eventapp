const crypto = require("crypto");

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
    return (req,res,next)=>{
        try {
            fun(req,res,next)
        } catch (error) {
            logError(error)
            return
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
module.exports = {
    RESPONSE,
    deleteImages,
    handleAsync,
    DateNowInMin,
    attendedInMin,
    logError,
    catchFun
}
