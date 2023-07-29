const express = require("express")
const {createUser, login, profile, updateProfile, logout } = require("../controller/usersController")
const router = express.Router()

router.route("/createUser").post(createUser)
router.route("/login").post(login)
router.route("/profile").post(profile)
router.route("/updateProfile").patch(updateProfile)
router.route("/logout").delete(logout)

module.exports = router