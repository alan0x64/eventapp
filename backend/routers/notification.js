const express = require('express');
const { mountpath } = require('../app');
const router = express.Router({ mergeParams: true });
const {notficationSender}=require("../controllers/notification");
const { authJWT_AT } = require('../middlewares/authn');
const { onlyOrgs, isOrgEventOwner } = require('../middlewares/authz');
const { catchFun } = require('../utils/shared_funs');


router.route('').post(
    authJWT_AT,
    onlyOrgs,
    isOrgEventOwner,
    catchFun(notficationSender))

module.exports=router