const express = require("express")
const {createUser, login, profile, updateProfile } = require("../controller/usersController")
const router = express.Router()

router.route("/createUser").post(createUser)
router.route("/login").post(login)
router.route("/profile").post(profile)
router.route("/updateProfile").patch(updateProfile)
module.exports = router