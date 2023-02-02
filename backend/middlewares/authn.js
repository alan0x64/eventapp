const express = require("express");
const jwt = require("jsonwebtoken");
const org = require("../models/org");
const user = require("../models/user")
const token_collection = require("../models/token")
const { RESPONSE, logError, handleAsync, catchFun } = require("../utils/shared_funs");


async function user_org(req,userORorg) {
    try {
        let logedinOrg = await org.findOne({ '_id': userORorg.id })
        let logedinUser = await user.findOne({ '_id': userORorg.id })
        
        if (logedinOrg==null && logedinUser==null ) {
            console.log("\nInvalid Tokens\n");
            return
        }

        if (logedinOrg) {
            req.logedinOrg = logedinOrg
        } else if (logedinUser) {
            req.logedinUser = logedinUser
        }

    } catch (error) {
        logError(error)
        return
    }
}

module.exports.authJWT_RT = catchFun(
    async function (req, res, next) {

        let authHeader = req.headers['authorization']
        let token = authHeader && authHeader.split(' ')[1]
        let tokenInDb = await token_collection.findOne({ 'RT': token })

        if (token == null || tokenInDb == null) return RESPONSE(res, 401)

        jwt.verify(token, process.env.REFRESH_TOKEN, async (err, userORorg) => {
            if (err) RESPONSE(res, 403)
            await user_org(req, res, userORorg)
            req.RT = token
            next()
        })

    }
)


module.exports.authJWT_AT = catchFun(
    function (req, res, next) {
        let authHeader = req.headers['authorization']
        let token = authHeader && authHeader.split(' ')[1]

        if (token == null) { return RESPONSE(res, 401) }

        jwt.verify(token, process.env.ACCESS_TOKEN, async (err, userORorg) => {
            if (err) RESPONSE(res, 403)
            await user_org(req, userORorg)
            next()
        })

    }
)
