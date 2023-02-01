const express = require("express");
const jwt = require("jsonwebtoken");
const org = require("../models/org");
const user = require("../models/user")
const token_collection = require("../models/token")
const { RESPONSE, logError } = require("../utils/shared_funs");

async function user_org(req,res,userORorg) {
    try {
        let logedinOrg = await org.findOne({ '_id': userORorg.id })
        let logedinUser = await user.findOne({ '_id': userORorg.id })

        if (logedinOrg) {
            req.logedinOrg = logedinOrg
        } else if (logedinUser) {
            req.logedinUser = logedinUser
        }
    } catch (err) {
        logError(err)
        RESPONSE(res, 500, { error: err.message })
    }
}

async function authJWT_RT(req, res, next) {
    try {
        let authHeader = req.headers['authorization']
        let token = authHeader && authHeader.split(' ')[1]
        let tokenInDb = await token_collection.findOne({ 'RT': token })

        if (token == null || tokenInDb == null) return RESPONSE(res, 401)

        jwt.verify(token, process.env.REFRESH_TOKEN, async (err, userORorg) => {
            if (err) RESPONSE(res, 403)
            await user_org(req,res,userORorg)
            req.RT = token
            next()
        })
    } catch (err) {
        logError(err)
        RESPONSE(res, 500, { error: err.message })
    }
}

function authJWT_AT(req, res, next) {
    try {
        let authHeader = req.headers['authorization']
        let token = authHeader && authHeader.split(' ')[1]

        if (token == null) { return RESPONSE(res, 401) }

        jwt.verify(token, process.env.ACCESS_TOKEN, async (err, userORorg) => {
            if (err) RESPONSE(res, 403)
            await user_org(req, userORorg)
            next()
        })
    } catch (err) {
        logError(err)
        RESPONSE(res, 500, { error: err.message })
    }
}

module.exports = { authJWT_RT, authJWT_AT }