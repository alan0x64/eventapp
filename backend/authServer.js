const express = require("express");
const cors = require("cors");
const database = require("./utils/database")
const app = express();
const xss = require("xss-clean")
const helmet = require("helmet");
const jwt = require("jsonwebtoken")
const mongoSanitize = require("express-mongo-sanitize")
const { authJWT_RT } = require("./middlewares/authn");
const { RESPONSE, logError, handleAsync, catchFun, logx, logger } = require("./utils/shared_funs");

//Settings
app.set('json spaces', 10)

//middleweres
app.use(logger);
app.use(express.json());
app.use(express.urlencoded({ extended: true }))
app.use(cors())
app.use(mongoSanitize())
app.use(xss())
app.use(helmet())

app.get('/test', handleAsync(async (req, res, next) => {
    RESPONSE(res, 200,"OK")
}))

//Routes
app.post('/RT', authJWT_RT, catchFun(
    (req, res) => {
        let id

        if (req.logedinUser) {
            id = req.logedinUser.id
        } else if (req.logedinOrg) {
            id = req.logedinOrg.id
        }

        if (id == null) throw Error("ID IS EMPTY")

        let AT = jwt.sign({
            id: id
        }, process.env.ACCESS_TOKEN, { expiresIn: "15m", algorithm: "HS512" })

        RESPONSE(res, 200, {
            AT: "Bearer " + AT
        })
    }
)
)

//Error Handler
app.use((err, req, res, next) => {
    logError(err)
    RESPONSE(res, 500, { error: err.message })
})

const PORT = process.env.AUTH_PORT || 9000
app.listen(PORT, () => {
    process.stdout.write('\033c');
    console.log(`\n\u2705 AuthServer Startred! ${process.env.HOST}:${PORT}/RT`)
})