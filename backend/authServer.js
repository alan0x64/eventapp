const express = require("express");
const cors = require("cors");
const database = require("./utils/database")
const app = express();
const xss=require("xss-clean")
const helmet = require("helmet");
const jwt = require("jsonwebtoken")
const mongoSanitize=require("express-mongo-sanitize")
const { authJWT_RT, authJWT_AT } = require("./middlewares/authn")

//Settings
app.set('json spaces', 10)

//middleweres
app.use(express.json());
app.use(express.urlencoded({ extended: true }))
app.use(cors())
app.use(mongoSanitize())
app.use(xss())
app.use(helmet())

//Routes
app.post('/RT', authJWT_RT, (req, res) => {
    let id

    if (req.logedinUser) {
        id = req.logedinUser.id
    } else if (req.logedinOrg) {
        id = req.logedinOrg.id
    }

    let AT = jwt.sign({
        id: id
    }, process.env.ACCESS_TOKEN, { expiresIn: "15m", algorithm: "HS512" })

    res.send({
        AT: "Bearer " + AT
    })
})

const PORT = process.env.AUTH_PORT || 9000
app.listen(PORT, () => {
    process.stdout.write('\033c');
    console.log(`\n\u2705 AuthServer Startred! [http://localhost:${PORT}/RT]`)
})