const jwt = require("jsonwebtoken")
const mysql = require("mysql")
const bcrypt = require("bcrypt")
const config = require("dotenv")
const { json } = require("express")
const isEmpty = require('lodash.isempty')
const { result: userData, reject, result } = require("lodash")
const { resolve } = require("path")
const { error } = require("console")
config.config({ path: "config/config.env" }) //change to base.env or create a config.env in config


var pwreg = /^(?=.*\d)(?=.*[a-z]).{8,10}$/
var emailreg = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/

const now = new Date()

//Datebase connection
const db = mysql.createConnection({
  host: process.env.HOST,
  user: process.env.DBUSER,
  password: process.env.PASSWORD,
  database: process.env.DATABASE,
})

//Global return result
var rMessage = "Invalid para"
var rCheck = false

//user table sql
const createtUserSQL = "INSERT INTO users (name, password, email, DOB, gender, dateOfCreation) VALUES (?, ?, ?, ?, ?, ?);"

//Query
exports.createUser = async (req, res) => {
  if (isEmpty(req.body)) {
    rMessage = "Invalid para"
    rCheck = false
    return res.send({ result: rMessage, check: rCheck })
  } else {
    rCheck = false
    if (!req.body.name) {
      rMessage = "Name is required"
      return res.send({ result: rMessage, check: rCheck })
    }
    if (!req.body.password) {
      rMessage = "Password is required"
      return res.send({ result: rMessage, check: rCheck })
    }
    if (!req.body.email) {
      rMessage = "Email is required"
      return res.send({ result: rMessage, check: rCheck })
    }
  }
  const name = req.body.name.trim()
  const password = req.body.password
  const email = req.body.email
  const dob = req.body.dob ? req.body.dob : null
  const gender = req.body.gender ? req.body.gender : null

  if (password.match(pwreg) && email.match(emailreg)) {
    const salt = bcrypt.genSaltSync(10)
    const hashPW = await bcrypt.hash(password, salt)
    db.query(createtUserSQL, [name, hashPW, email, dob, gender, now], async (err, result) => {
      if (err) {
        rMessage = "Try again later" //can be db fail to connect, can be duplicate primary key, sql value is wrong
        rCheck = false
      } else {
        rMessage = "Added"
        rCheck = true
      }
      return res.send({ result: rMessage, check: rCheck })
    })
  } else {
    rCheck = false
    if (!password.match(pwreg)) {
      rMessage = "Invalid Password format"
    } else if (!email.match(emailreg)) {
      rMessage = "Invalid Email format"
    }
    return res.send({ result: rMessage, check: rCheck })
  }
}
