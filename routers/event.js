const express = require('express');
const router = express.Router({ mergeParams: true });
const event = require('../controllers/event')
const { authJWT_AT } = require("../middlewares/authn")
const { eventImageHandler } = require("../middlewares/file_handler")
const { onlyUsers, isOrgEventOwner,onlyOrgs } = require("../middlewares/authz")


//GET
router.route('/').get(authJWT_AT,onlyUsers ,event.getEvents)
router.route('/owner/:eventId').get(authJWT_AT,onlyUsers,event.getEventOwner)

router.route('/info/:eventId').get(authJWT_AT,isOrgEventOwner,event.getEvent)
router.route('/members/:eventId').get(authJWT_AT,isOrgEventOwner, event.getEventMembers)

router.route('/certificate/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, event.genCerts)
router.route('/blacklist/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, event.getBlockedMembers)


//PATCH
router.route('/checkin/:eventId').patch(authJWT_AT, event.checkIn)
router.route('/checkout/:eventId').patch(authJWT_AT, event.checkOut)
router.route('/update/:eventId').patch(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    eventImageHandler.single('eventBackgroundPic'),
    event.updateEvent)


//POST
router.route('/register').post(
    authJWT_AT,
    onlyOrgs,
    eventImageHandler.fields([
        { name: 'eventBackgroundPic' },
        { name: 'sig' },
    ]),
    event.createEvent)



//DELETE
router.route('/delete/:eventId').delete(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    event.deleteEvent)


module.exports = router