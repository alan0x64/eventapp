var fireadmin = require("firebase-admin")
var fcm = require("fcm-notification")
var serviceAccount = require("../config/push.json")
const { logx, RESPONSE } = require("../utils/shared_funs")
const event = require("../models/event")
const certPath = fireadmin.credential.cert(serviceAccount)
var FCM = new fcm(certPath)

module.exports.notficationSender = async (req, res, sendRes) => {
    if (sendRes == null) sendRes = 1
    try {
        let eventId = req.body.eventId || req.params.eventId
        let eventx = await event.findById(eventId)

        notification = {
            title: `A Event Has Started`,
            body: `${eventx.title} Has Started`,
            sound: "default"
        }

        if (eventx.status == 2) {
            notification['title'] = 'A Event Has Just Ended',
                notification['body'] = `${eventx.title} Has Ended`
        }


        let message = {
            android: { notification },
            data: {
                eventId: eventId,
                eventTitle: eventx.title,
                ...notification
            },
            topic: eventx.id,
        }

        FCM.send(message, () => { })
        if (sendRes)
            return RESPONSE(res, 200, 'Notification Send!')
    } catch (err) {
        console.log(err);
        if (sendRes)
            return RESPONSE(res, 200, `Error while trying to send notification`)
    }
}


module.exports.unsubscribeNotification = async (req, res, next) => {
    try {
        let topic = req.body.eventId
        let token = req.body.devId
        FCM.unsubscribeFromTopic(token, topic, () => { })
        RESPONSE(res, 200, `Unsubscribed ${token} From ${topic}`)
    } catch (err) {
        logx(err);
        RESPONSE(res, 200, `Error while trying to unsubscribed`)
    }
}