const express = require('express');
const router = express.Router({ mergeParams: true });
const org = require('../controllers/org')
const { authJWT_RT, authJWT_AT } = require("../middlewares/authn")
const { onlyUsers, isOrgEventOwner,onlyOrgs } = require("../middlewares/authz")
const { orgImageHandler } = require("../middlewares/file_handler")

//GET
router.route('/profile').get(authJWT_AT,onlyOrgs, org.getLogedInOrg)
router.route('/profile/:id').get(authJWT_AT, onlyUsers, org.getOrg)
router.route('/events').get(authJWT_AT,onlyOrgs, org.getOrgEvents)
router.route('/events/:orgId').get(authJWT_AT, onlyUsers, org.getParticularOrgEvents)

//POST
router.route('/login').post(org.login)
router.route('/logout').post(authJWT_RT,onlyOrgs,org.logout)
router.route('/:userId/:eventId')
    .post(authJWT_AT,onlyOrgs,isOrgEventOwner, org.BLUser)
    .delete(authJWT_AT,onlyOrgs,isOrgEventOwner, org.UBLUser)

router.route('/register').post(
    orgImageHandler.fields([
        { name: 'orgPic' },
        { name: 'orgBackgroundPic' },
    ]),
    org.createOrg)


//DELETE
router.route('/delete').delete(authJWT_AT,onlyOrgs,org.deleteOrg)


//PATCH
router.route('/update').patch(
    authJWT_AT,
    onlyOrgs,
    orgImageHandler.fields([
        { name: 'orgPic' },
        { name: 'orgBackgroundPic' },
    ]),
    org.updateOrg)


module.exports = router

