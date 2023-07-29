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
const AccessKey = process.env.ACCESSKEY
//const time = process.env.TIME //for jwt token time expired


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
const checkUserExistSQL = "SELECT * FROM users WHERE name = ?;"

//user token sql
const loginSQL = "INSERT INTO userSession (token, name, device) VALUES (?, ?, ?);"
const checkSessionSQL = "SELECT * FROM userSession WHERE name =? AND token = ?;"
const checkSessionSQLF = "SELECT * FROM userSession WHERE name =? AND token = ? AND device = ?;"//future implication

//Token
function genAccessToken(userInfo, device) {
  const toeknPayLoad = { username: userInfo.name, device: device }
  const accessToken = jwt.sign(toeknPayLoad, AccessKey, {})
  return accessToken
}

//decode jwtToken
/*
function verifyJWT(token) {
  let isToken
  if (token === undefined || token === null) {
    return "Token not here"
  } else {
    jwt.verify(token, AccessKey, (e, decode) => {
      if (e) {
        isToken = false
      } else {
        isToken = decode
      }
    })
  }
  return isToken
}
*/

//check function
async function checkToken(name, token) {
  return new Promise((resolve, reject) => {
    db.query(checkSessionSQL, [name, token], (err, result) => {
      if (err) {
        return resolve(false)
      } else {
        if (result.length > 0) {
          return resolve(true)
        }
        return resolve(false)
      }
    })
  })
}

async function checkUserExist(name) {
  return new Promise((resolve, reject) => {
    db.query(checkUserExistSQL, [name], (err, result) => {
      if (err) {
        return resolve("fail")
      } else {
        if (result.length > 0) {
          return resolve(result)
        }
        return resolve("Wrong username/password combination") //user does not exist
      }
    })
  })
}

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

exports.login = async (req, res) => {
  if (isEmpty(req.body)) {
    rMessage = "Invalid para"
    rCheck = false
    return res.send({ result: rMessage, check: rCheck })
  }
  const name = req.body.name
  const password = req.body.password
  const device = req.body.device ? req.body.device : "mac" //future implication
  if (name && password) {
    const userData = await checkUserExist(name)
    if (typeof userData === "string") { //user does not exist or db fail
      rCheck = false
      return res.send({ result: userData, check: rCheck })
    } else { //user exist
      const match = await bcrypt.compare(password, userData[0].password)
      if (match) { //password is correct
        const token = genAccessToken(userData[0], device)
        db.query(loginSQL, [token, name, device], async (err, r) => {
          if (err) {
            rMessage = "Fail"
            rCheck = false
            return res.send({ result: rMessage, check: rCheck })
          } else {
            rMessage = "successfully"
            rCheck = true
            return res.send({ result: rMessage, check: rCheck, token: token })
          }
        })
      } else { //password fail
        rMessage = "Wrong name/password combination"
        rCheck = false
        return res.send({ result: rMessage, check: rCheck })
      }
    }
  } else {
    rMessage = "Name/password is empty"
    rCheck = false
    return res.send({ result: rMessage, check: rCheck })
  }
}

exports.profile = async (req, res) => {
  if (isEmpty(req.body)) {
    rMessage = "Invalid para"
    rCheck = false
    return res.send({ result: rMessage, check: rCheck })
  }
  const name = req.body.name
  const token = req.body.token
  const device = req.body.device ? req.body.device : "mac" //future implication
  const tokenResult = await checkToken(name, token)
  if (tokenResult) {
    const userData = await checkUserExist(name)
    if (typeof userData === "object") { //user exist
      rCheck = true
    }else{
      rCheck = false
    }
    const date = new Date(userData[0]["DOB"]);
    userData[0]["DOB"] = date.toLocaleDateString() === "1/1/1970" ? null : date.toLocaleDateString() //to send localDate
    return res.send({ result: userData, check: rCheck })
  } else {
    rMessage = "jwt fail"
    rCheck = false
    return res.send({ result: rMessage, check: rCheck })
  }
}