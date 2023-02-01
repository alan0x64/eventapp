require("./utils/database")
const express = require("express");
const cors = require("cors");
const app = express();
const path = require("path")
const xss=require("xss-clean");
const userRouter = require("./routers/user")
const eventRouter = require("./routers/event")
const orgRouter = require("./routers/org")
const user = require("./models/user");
const event = require("./models/event");
const helmet = require("helmet");
const org = require("./models/org");
const token = require("./models/token");
const { authJWT_AT } = require("./middlewares/authn")
const mongoSanitize = require("express-mongo-sanitize");
const { handleAsync, RESPONSE, logError } = require("./utils/shared_funs");
const morgan = require("morgan");
const {fileHeaders}=require("./middlewares/file_headers")

//Settings
app.set('json spaces', 10)
  
//Some Middleweres
app.use(express.json());
app.use(express.urlencoded({ extended: true }))
app.use(mongoSanitize())
app.use(xss())
app.use(helmet())
app.use(morgan('dev'))

app.use('/uploads',fileHeaders,express.static(path.join(__dirname, '/public')))
app.use('/uploads',fileHeaders,express.static(path.join(__dirname, '/images')))
app.use(cors())

//Routers
app.use('/user', userRouter)
app.use('/org', orgRouter)
app.use('/event', eventRouter)


app.get('/test', handleAsync(async (req, res,next) => {
    RESPONSE(res,200,"OK")
}))


app.get('/RESET', async (req, res) => {
    await user.deleteMany({})
    await org.deleteMany({})
    await event.deleteMany({})
    await token.deleteMany({})
    RESPONSE(res,200,"RESETED THE DB")
})

//Error Handler
app.use((err,req,res,next)=>{
    logError(err)
    RESPONSE(res,500,{error:err.message})
})

const PORT = process.env.PORT || 4000
app.listen(PORT, async () => {
    process.stdout.write('\x1Bc');
    console.log(`\n\u2705 Startred Server! ${process.env.HOST}:${PORT}`)
})

module.exports = app

