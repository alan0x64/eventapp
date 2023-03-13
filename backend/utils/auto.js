const { notficationSender } = require("../controllers/notification")
const event = require("../models/event")
const { DateNowInMin, toMin, genCerts } = require("./shared_funs")

async function autoEvent(req,res,eventId){
    let eventx = await event.findById(eventId)
    
    if (eventx.status != 1 && eventx.status != 2  && DateNowInMin() < toMin(eventx.endDateTime) && DateNowInMin() > toMin(eventx.startDateTime)) {
        await eventx.updateOne({
            'status': 1
        })
        notficationSender(req, res, 0)
    }
 
    if (eventx.status != 2 && DateNowInMin() > toMin(eventx.endDateTime)) {
        genCerts(req, res, 0)
        await eventx.updateOne({
            'status': 2
        })
 
        notficationSender(req, res, 0)
    }
    
    return 
 }
 
 module.exports=autoEvent