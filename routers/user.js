const express = require('express');
const router = express.Router({mergeParams:true});
const user=require('../controllers/user')
const {authJWT_RT,authJWT_AT}=require("../middlewares/authn")
const {userImageHandler} =require("../middlewares/file_handler")
const { onlyUsers, isOrgEventOwner } = require("../middlewares/authz")

//GET
router.route('/profile').get(authJWT_AT,onlyUsers,user.getLogedInUser)
router.route('/profile/:id').get(authJWT_AT,user.getUser)
router.route('/cert/:eventId').get(authJWT_AT,onlyUsers,user.getCertificate)

//POST
router.route('/register').post(userImageHandler.single('profilePic'),user.createUser)
router.route('/login').post(user.login)
router.route('/logout').post(authJWT_RT,onlyUsers,user.logout)

//PATCH
router.route('/update').patch(authJWT_AT,onlyUsers,userImageHandler.single('profilePic'),user.updateUser)
router.route('/join/:eventId').patch(authJWT_AT,onlyUsers,user.AddUserToEvent)

//DELETE
router.route('/delete').delete(authJWT_AT,onlyUsers,user.deleteUser)
router.route('/quit/:eventId').delete(authJWT_AT,onlyUsers,user.RemoveUserFromEvent)


module.exports=router
