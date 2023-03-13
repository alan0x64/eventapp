const express = require('express');
const router = express.Router({ mergeParams: true });
const event = require('../controllers/event')
const { authJWT_AT } = require("../middlewares/authn")
const { eventImageHandler,handleEventImages } = require("../middlewares/file_handler")
const { onlyUsers, isOrgEventOwner,onlyOrgs } = require("../middlewares/authz")
const { validateEvent,validateCheckInOut } = require("../middlewares/validators");
const { handleAsync, validateObjectID, catchFun } = require('../utils/shared_funs');



//GET
router.route('').get(authJWT_AT,onlyUsers , handleAsync(event.getEvents))
router.route('/owner/:eventId').get(authJWT_AT,onlyUsers,handleAsync(event.getEventOwner))

router.route('/info/:eventId').get(authJWT_AT,isOrgEventOwner,handleAsync(event.getEvent))
router.route('/members/:eventId').get(authJWT_AT,isOrgEventOwner, handleAsync(event.getEventMembers))

router.route('/certificate/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.makeCerts))

router.route('/certificate/:userId/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.genCert))

router.route('/blacklist/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.getBlockedMembers))


router.route('/attenders/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner, handleAsync(event.getAttenders))

router.route('/certs/:eventId').get(authJWT_AT,onlyOrgs,isOrgEventOwner,handleAsync(event.getEventCerts))





//PATCH
router.route('/checkin').patch(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    validateCheckInOut,
    catchFun(validateObjectID),
    handleAsync(event.checkIn))

router.route('/checkout').patch(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    validateCheckInOut,
    validateObjectID,
    handleAsync(event.checkOut)
    )

router.route('/update/:eventId').
put(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    eventImageHandler.fields([
        { name: 'eventBackgroundPic' },
        { name: 'sig' },
    ]),
    validateEvent,
    handleAsync(event.updateEvent)).
patch(
        authJWT_AT,
        onlyOrgs,
        isOrgEventOwner,
        validateEvent,
        handleAsync(event.updateEvent)
    )

router.route('/:userId/:eventId').patch(authJWT_AT,isOrgEventOwner, handleAsync(event.removeUserFromEvent))

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
    
router.route('/search').post(authJWT_AT,isOrgEventOwner, handleAsync(event.search))



//DELETE
router.route('/delete/:eventId').delete(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    handleAsync(event.deleteEvent))


module.exports = router