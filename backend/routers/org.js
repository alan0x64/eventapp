const express = require('express');
const router = express.Router({ mergeParams: true });
const org = require('../controllers/org')
const { authJWT_RT, authJWT_AT } = require("../middlewares/authn")
const { onlyUsers, isOrgEventOwner, onlyOrgs } = require("../middlewares/authz")
const { orgImageHandler } = require("../middlewares/file_handler")
const { validatePassword, validateOrg, validateLogin, validateUpdateOrg } = require("../middlewares/validators");
const { handleAsync } = require('../utils/shared_funs');


//GET
router.route('/profile').get(authJWT_AT, onlyOrgs, handleAsync(org.getLogedInOrg))
router.route('/profile/:id').get(authJWT_AT, onlyUsers, handleAsync(org.getOrg))
router.route('/events').get(authJWT_AT, onlyOrgs, handleAsync(org.getOrgEvents))
router.route('/events/:orgId').get(authJWT_AT, onlyUsers, handleAsync(org.getParticularOrgEvents))

//POST
router.route('/login').post(validateLogin, handleAsync(org.login))
router.route('/logout').post(authJWT_RT, onlyOrgs, handleAsync(org.logout))
router.route('/:userId/:eventId')
.post(authJWT_AT, onlyOrgs, isOrgEventOwner, handleAsync(org.BLUser))
    .delete(authJWT_AT, onlyOrgs, isOrgEventOwner, handleAsync(org.UBLUser))

router.route('/register').post(
    orgImageHandler.fields([
        { name: 'orgPic' },
        { name: 'orgBackgroundPic' },
    ]),
    validateOrg,
    handleAsync(org.createOrg))


//DELETE
router.route('/delete').delete(authJWT_AT, onlyOrgs, handleAsync(org.deleteOrg))


//PATCH
router.route('/update').patch(
    authJWT_AT,
    onlyOrgs,
    validateUpdateOrg,
    orgImageHandler.fields([
        { name: 'orgPic' },
        { name: 'orgBackgroundPic' },
    ]),
    handleAsync(org.updateOrg)
)

// PUT
router.route('/update/x').put(
    authJWT_AT,
    onlyOrgs,
    validateUpdateOrg,
    handleAsync(org.updateOrgx)
)

router.route('/updatepassword').put(
    authJWT_AT,
    onlyOrgs,
    validatePassword,
    handleAsync(org.updatePassword)
)


module.exports = router

