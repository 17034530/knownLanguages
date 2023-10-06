package controllers

import (
	"encoding/json"
	"io/ioutil"
	"myModule/config"
	"myModule/entities"
	"myModule/models"
	"net/http"
	"strings"
)

func CreateUser(res http.ResponseWriter, req *http.Request) {
	db, err := config.GetMySQLDB()
	if err == nil {
		defer db.Close()
		userModel := models.USERDB{
			Db: db,
		}

		body, err := ioutil.ReadAll(req.Body)
		if err == nil {

			user := entities.Users{}
			err = json.Unmarshal(body, &user)
			if err != nil {
				WriteJsonMsg(res, "Invalid para", false)
				return
			}
			name := strings.TrimSpace(user.Name)
			if name == "" {
				WriteJsonMsg(res, "Name is required", false)
				return
			}
			if user.Password == "" {
				WriteJsonMsg(res, "Password is required", false)
				return
			}
			if user.Email == "" {
				WriteJsonMsg(res, "Email is required", false)
				return
			}

			if !models.RegexPW(user.Password) {
				WriteJsonMsg(res, "Invalid Password format", false)
				return
			}
			if !models.RegexEmail(user.Email) {
				WriteJsonMsg(res, "Invalid Email format", false)
				return
			}

			var dob *string
			if len(user.Dob) > 0 {
				dob = &user.Dob
			}
			var gender *string
			if len(user.Gender) > 0 {
				gender = &user.Gender
			}

			hashpw, err := models.HashPassword(user.Password)
			if err == nil {

				check, err := userModel.CreateUser(name, hashpw, user.Email, dob, gender)
				if err != nil {
					WriteJsonMsg(res, "Try again later", false)
					return
				}

				if check {
					WriteJsonMsg(res, "Added", check)
					return
				}
			}
		}
	}
}

func Login(res http.ResponseWriter, req *http.Request) {
	db, err := config.GetMySQLDB()
	if err == nil {
		defer db.Close()
		userModel := models.USERDB{
			Db: db,
		}
		body, err := ioutil.ReadAll(req.Body)
		if err == nil {
			user := entities.UserLogin{}
			err = json.Unmarshal(body, &user)
			if err != nil {
				WriteJsonMsg(res, "Invalid para", false)
				return
			}
			if user.Name == "" || user.Password == "" {
				WriteJsonMsg(res, "Name/password is empty", false)
				return
			}
			result, check, err := userModel.Login(user.Name, user.Password, user.Device)
			if err != nil {
				WriteJsonMsg(res, result, check)
				return
			}
			if check {
				WriteJsonLoginMsg(res, "Successfully", check, result)
				return
			} else {
				WriteJsonMsg(res, "Wrong name/password combination", check)
				return
			}
		}
	}
}

func Profile(res http.ResponseWriter, req *http.Request) {
	db, err := config.GetMySQLDB()
	if err == nil {
		defer db.Close()
		userModel := models.USERDB{
			Db: db,
		}

		body, err := ioutil.ReadAll(req.Body)
		if err == nil {
			user := entities.UserSession{}
			err = json.Unmarshal(body, &user)
			if err != nil {
				WriteJsonMsg(res, "Invalid para", false)
				return
			}

			result, check := userModel.Profile(user.Name, user.Token)
			WriteJsonProfileMsg(res, result, check)
			return
		}
	}
}

func UpdateProfile(res http.ResponseWriter, req *http.Request) {
	db, err := config.GetMySQLDB()
	if err == nil {
		defer db.Close()
		userModel := models.USERDB{
			Db: db,
		}

		body, err := ioutil.ReadAll(req.Body)
		if err == nil {
			user := entities.UserUpdate{}
			err = json.Unmarshal(body, &user)
			if err != nil {
				WriteJsonMsg(res, "Invalid para", false)
				return
			}

			if user.Password == "" {
				WriteJsonMsg(res, "Password is required", false)
				return
			}
			if user.Email == "" {
				WriteJsonMsg(res, "Email is required", false)
				return
			}

			var hashpw string
			if user.NewPassword != "" && !models.RegexPW(user.NewPassword) {
				WriteJsonMsg(res, "Invalid new password format", false)
				return
			} else if user.NewPassword != "" { //new password wrong format
				hashpw, err = models.HashPassword(user.NewPassword)
				if err != nil {
					WriteJsonMsg(res, "Invalid new password format", false)
					return
				}
			}

			if !models.RegexEmail(user.Email) {
				WriteJsonMsg(res, "Invalid Email format", false)
				return
			}

			var dob *string
			if len(user.Dob) > 0 {
				dob = &user.Dob
			}
			var gender *string
			if len(user.Gender) > 0 {
				gender = &user.Gender
			}

			result, check := userModel.UpdateProfile(user.Name, user.Password, hashpw, user.Email, dob, gender, user.Token)
			WriteJsonMsg(res, result, check)
			return
		}
	}
}

func Logout(res http.ResponseWriter, req *http.Request) {
	db, err := config.GetMySQLDB()
	if err == nil {
		defer db.Close()
		userModel := models.USERDB{
			Db: db,
		}

		body, err := ioutil.ReadAll(req.Body)
		if err == nil {
			user := entities.UserToken{}
			err = json.Unmarshal(body, &user)
			if err != nil {
				WriteJsonMsg(res, "Invalid para", false)
				return
			}

			result, check := userModel.Logout(user.Name, user.Token)
			WriteJsonMsg(res, result, check)
			return
		}
	}
}
