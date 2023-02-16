const express = require('express');
const router = express.Router({ mergeParams: true });
const event = require('../controllers/event')
const { authJWT_AT } = require("../middlewares/authn")
const { eventImageHandler } = require("../middlewares/file_handler")
const { onlyUsers, isOrgEventOwner,onlyOrgs } = require("../middlewares/authz")
const { validateEvent } = require("../middlewares/validators");
const { handleAsync } = require('../utils/shared_funs');



//GET
router.route('/').get(authJWT_AT,onlyUsers , handleAsync(event.getEvents))
router.route('/owner/:eventId').get(authJWT_AT,onlyUsers,handleAsync(event.getEventOwner))

router.route('/info/:eventId').get(authJWT_AT,isOrgEventOwner,handleAsync(event.getEvent))
router.route('/members/:eventId').get(authJWT_AT,isOrgEventOwner, handleAsync(event.getEventMembers))

router.route('/certificate/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.genCerts))

router.route('/certificate/:userId/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.genCert))

router.route('/blacklist/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.getBlockedMembers))


//PATCH
router.route('/checkin/:eventId').patch(authJWT_AT,onlyUsers,handleAsync(event.checkIn))
router.route('/checkout/:eventId').patch(authJWT_AT,onlyUsers, handleAsync(event.checkOut))
router.route('/update/:eventId').patch(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    validateEvent,
    eventImageHandler.single('eventBackgroundPic'),
    handleAsync(event.updateEvent))


//POST
router.route('/register').post(
    authJWT_AT,
    onlyOrgs,
    eventImageHandler.fields([
        { name: 'eventBackgroundPic' },
        { name: 'sig' },
    ]),
    validateEvent, 
    handleAsync(event.createEvent))



//DELETE
router.route('/delete/:eventId').delete(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    handleAsync(event.deleteEvent))


module.exports = router