const express = require('express');
const router = express.Router({ mergeParams: true });
const user = require('../controllers/user')
const { authJWT_RT, authJWT_AT } = require("../middlewares/authn")
const { userImageHandler } = require("../middlewares/file_handler")
const { onlyUsers,onlyOrgs,isOrgEventOwner } = require("../middlewares/authz")
const { validateUser, validateLogin, validatePassword } = require("../middlewares/validators");
const { handleAsync } = require('../utils/shared_funs');


//GET
router.route('/profile').get(authJWT_AT, onlyUsers, handleAsync(user.getLogedInUser))
router.route('/profile/:id').get(authJWT_AT, handleAsync(user.getUser))
router.route('/cert/:eventId').get(authJWT_AT, onlyUsers, handleAsync(user.getCertificate))
router.route('/events').get(authJWT_AT, onlyUsers, handleAsync(user.getJoinedEvents))


//POST
router.route('/register').post(
    userImageHandler.single('profilePic'),validateUser, handleAsync(user.createUser))

router.route('/login').post(validateLogin,handleAsync(user.login))
router.route('/logout').post(authJWT_RT, onlyUsers, handleAsync(user.logout))
router.route('/search').post(authJWT_AT, onlyOrgs,isOrgEventOwner, handleAsync(user.search))

//PATCH
router.route('/update').
put(
    authJWT_AT,
    onlyUsers,
    userImageHandler.single('profilePic'),
    validateUser,
    handleAsync(user.updateUser)
    ).
patch(
    authJWT_AT,
    onlyUsers,
    validateUser,
    handleAsync(user.updateUser)
)



router.route('/updatepassword').put(
    authJWT_AT,
    onlyUsers,
    validatePassword,
    handleAsync(user.updatePassword)
)

router.route('/join/:eventId').patch(authJWT_AT, onlyUsers, handleAsync(user.AddUserToEvent))

//DELETE
router.route('/delete').delete(authJWT_AT, onlyUsers, handleAsync(user.deleteUser))
router.route('/quit/:eventId').delete(authJWT_AT, onlyUsers, handleAsync(user.RemoveUserFromEvent))


module.exports = router
