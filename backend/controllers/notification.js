var fireadmin = require("firebase-admin")
var fcm = require("fcm-notification")
var serviceAccount = require("../config/push.json")
const { logx, RESPONSE } = require("../utils/shared_funs")
const event = require("../models/event")
const certPath = fireadmin.credential.cert(serviceAccount)
var FCM = new fcm(certPath)

module.exports.notficationSender =  async (req, res, next) =>  {
    try {
        let eventId=req.body.eventId
        let eventx=await event.findById(eventId)
        let message={
            android:{
                notification:{
                    title:`A Event Has Started`,
                    body:`${eventx.title} Has Started`,
                    sound:"default"
                },    
            },
            data:{
              eventId:eventId, 
              eventTitle:eventx.title
            },
        topic:eventx.id,
        }
        
        FCM.send(message,()=>{})
        RESPONSE(res,200,{'eventId':eventx.id,'eventTitle':eventx.title})
    } catch (err) {
        logx(err);
    }
}