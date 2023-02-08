const baseJoi = require("joi");
const DOMPurify = require('isomorphic-dompurify');
const { logError } = require("../utils/shared_funs");

const sanitizeData=(str)=>{
    try {
        str = str.replace(/<[^>]*>/g, "");
        let clean = DOMPurify.sanitize(str);

        //Remove the javascript and vbscript by using a regular expression
        clean = clean.replace(/javascript/gi, "");
        clean = clean.replace(/vbscript/gi, "");

        //Remove any on* attributes such as onload or onclick
        clean = clean.replace(/on\w+="[^"]*"/gi, "");

        return clean;
    } catch (error) {
       logError(error)
    }
}


const extension = (joi) => ({
    type: 'string',
    base: joi.string(),
    messages: {
        'string.escapeHTML': '{{#label}} must not include HTML!'
    },
    rules: {
        escapeHTML: {
            validate(value, helpers) {
                const clean = sanitizeData(value)
                if (clean !== value) return helpers.error('string.escapeHTML', { value })
                return clean
            }
        }
    }

})

const joi = baseJoi.extend(extension)

const validLoginSchema = joi.object({
    email: joi.string().escapeHTML().lowercase().email().required().error(new Error("Invalid Email")),
    password: joi.string().escapeHTML().required().error(new Error("Invalid Password")),
})

const validUserSchema = joi.object({
    fullName: joi.string().escapeHTML().required().error(new Error("Invalid FullName")),
    email: joi.string().escapeHTML().lowercase().email().required().error(new Error("Invalid Email")),
    password: joi.string().escapeHTML().required().error(new Error("Invalid Password")),
    phoneNumber: joi.number().required().error(new Error("Invalid PhoneNumber Or Phone Number Is Already In Use")),
    date_of_birth: joi.date().min('1-1-1950').required().error(new Error("Invaild Data And Birth")),
    university: joi.string().escapeHTML().default("None"),
    faculty: joi.string().escapeHTML().default("None"),
    department: joi.string().escapeHTML().default("None"),
    scientific_title: joi.string().escapeHTML().default("None"),
    bio: joi.string().escapeHTML().default("None"),
})

const validOrgSchema = joi.object({
    orgName: joi.string().escapeHTML().required().error(new Error('Invalid OrgName')),
    email: joi.string().escapeHTML().lowercase().email().required().error(new Error('Invalid Email')),
    phoneNumber: joi.number().required().error(new Error('Invalid Phone Number or Phone Number Is Already Used')),
    org_type: joi.number().valid(0, 1, 2).default(0).error(new Error('Invalid Org Type')),
    bio: joi.string().escapeHTML().default("None"),
    website:joi.string().escapeHTML().default("None"),
    socialMedia:joi.string().escapeHTML().default("None"),
    location: joi.string().escapeHTML().default("None"),
    password: joi.string().escapeHTML().required().error(new Error('Invalid Password')),
});

const validUpdateOrgSchema = joi.object({
    orgName: joi.string().escapeHTML().required().error(new Error('Invalid OrgName')),
    email: joi.string().escapeHTML().lowercase().email().required().error(new Error('Invalid Email')),
    phoneNumber: joi.number().required().error(new Error('Invalid Phone Number or Phone Number Is Already Used')),
    org_type: joi.number().valid(0, 1, 2).default(0).error(new Error('Invalid Org Type')),
    bio: joi.string().escapeHTML().default("None"),
    location: joi.string().escapeHTML().default("None"),
    website:joi.string().escapeHTML().default("None"),
    socialMedia:joi.string().escapeHTML().default("None"),
});

const validPasswordSchema = joi.object({
    password: joi.string().escapeHTML().required().error(new Error('Invalid Password')),
});

const validEventSchema = joi.object({
    title: joi.string().escapeHTML().required().error(new Error('Invalid Event Title')),
    description: joi.string().escapeHTML().default('None'),
    location: joi.string().escapeHTML().default('None'),
    status: joi.number().valid(0, 1, 2).default(0).error(new Error('Invalid Event Status')),
    eventType: joi.number().valid(0, 1).default(0).error(new Error('Invalid Event Type')),
    startDateTime: joi.date().min('now').required().error(new Error('Invalid Start Date&Time')),
    endDateTime: joi.date().min('now').required().error(new Error('Invalid End Date&Time')),
    minAttendanceTime: joi.number().min(0).default(0).error(new Error('Invalid Minimum Attendance Time')),
    sets: joi.number().min(1).default(1).error(new Error('Invalid Number Of Sets')),
    Attenders: joi.number().min(0).default(0).error(new Error('Invalid Number Of Attenders')),
    Attended: joi.number().min(0).default(0).error(new Error('Invalid Number Of Attended')),
    orgId: joi.string().escapeHTML().required().error(new Error('Invalid OrgId')),
});

module.exports = {
    sanitizeData,
    validUserSchema,
    validOrgSchema,
    validEventSchema,
    validLoginSchema,
    validUpdateOrgSchema,
    validPasswordSchema
}