package models

import (
	"database/sql"
	"myModule/entities"
	"os"
	"regexp"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

type USERDB struct {
	Db *sql.DB
}

type NULL struct {
	Null sql.NullString
}

const pwreg = `^[a-zA-Z0-9!@#$%^&*()_+\[\]{};:'",.<>/?\\-\\=].{8,10}$`
const emailreg = `^[a-zA-Z0-9.!#$%&'*+/=?^_{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$`

// user table sql
const createtUserSQL = "INSERT INTO users (name, password, email, DOB, gender, dateOfCreation) VALUES (?, ?, ?, ?, ?, ?);"
const checkUserExistSQL = "SELECT * FROM users WHERE name = ?;"
const updateAllSQL = "UPDATE users SET password = ?, email = ?, dob = ?, gender = ? WHERE (name = ?);"
const updateEmailSQL = "UPDATE users SET email = ?, dob = ?, gender = ? WHERE (name = ?);"

// user token sql
const loginSQL = "INSERT INTO userSession (token, name, device) VALUES (?, ?, ?);"
const checkSessionSQL = "SELECT * FROM userSession WHERE name =? AND token = ?;"
const checkSessionSQLF = "SELECT * FROM userSession WHERE name =? AND token = ? AND device = ?;" //future implication
const logoutSQL = "DELETE FROM userSession WHERE (token = ?);"

func GenAccessToken(name string, device string) (string, error) {
	cfg := godotenv.Load("config/config.env")
	if cfg != nil {
		// log.Fatal("Error: env fail to load - models")
		return "Fail", cfg
	}
	tokenPlayLoad := jwt.MapClaims{
		"username": name,
		"device":   device,
		"iat":      time.Now().Local().Add(time.Hour * time.Duration(24)).Unix(), //same default as nodejs
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, tokenPlayLoad)
	signedToken, err := token.SignedString([]byte(os.Getenv("ACCESSKEY")))
	if err != nil {
		// log.Fatal("Error: JWT sign fail")
		return "", err
	}
	return signedToken, nil
}

func RegexPW(password string) bool {

	r, err := regexp.Compile(pwreg)
	if err != nil {
		return false
	}
	return r.MatchString(password)
}

func RegexEmail(email string) bool {
	r, err := regexp.Compile(emailreg)
	if err != nil {
		return false
	}
	return r.MatchString(email)
}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func (d USERDB) CheckUserExist(name string) (entities.UserDB, bool, error) {
	user := entities.UserDB{}
	checkUserExist, err := d.Db.Query(checkUserExistSQL, name)
	if err != nil {
		return user, false, err
	}
	a := 0
	for checkUserExist.Next() {
		a++
		err := checkUserExist.Scan(&user.Name, &user.Password, &user.Email, &user.Dob, &user.Gender, &user.Doc)
		if err != nil {
			return user, false, err
		}
	}
	if a == 1 {
		return user, true, nil
	}
	return user, false, nil
}

func (d USERDB) CheckToken(name string, token string) bool {
	checkUserToken, err := d.Db.Query(checkSessionSQL, name, token)
	if err == nil {
		a := 0
		for checkUserToken.Next() {
			a++
		}
		if a == 1 {
			return true
		}
	}
	return false
}

func (d USERDB) UpdateAll(password string, email string, dob *string, gender *string, name string) (string, bool) {
	_, err := d.Db.Query(updateAllSQL, password, email, dob, gender, name)
	if err != nil {
		return "Fail", false
	}
	return "Profile updated", true
}

func (d USERDB) UpdateEmail(email string, dob *string, gender *string, name string) (string, bool) {
	_, err := d.Db.Query(updateEmailSQL, email, dob, gender, name)
	if err != nil {
		return "Fail", false
	}
	return "Profile updated", true
}

func (d USERDB) CreateUser(name string, password string, email string, DOB *string, gender *string) (bool, error) {
	currentTime := time.Now()
	_, err := d.Db.Query(createtUserSQL, name, password, email, DOB, gender, currentTime)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (d USERDB) Login(name string, password string, device string) (string, bool, error) {
	userData := entities.UserDB{}
	userData, check, err := d.CheckUserExist(name)
	if err != nil {
		return "Fail", false, err //db fail
	}
	if !check {
		return "Wrong name/password combination", false, err //user does not exist
	}
	if CheckPasswordHash(password, userData.Password) {
		token, tokenErr := GenAccessToken(name, device)
		if tokenErr != nil {
			return "Fail", false, tokenErr
		}
		if device == "" {
			device = "mac"
		}
		_, insertErr := d.Db.Query(loginSQL, token, name, device)
		if insertErr != nil {
			return "Fail", false, insertErr
		}
		return token, true, nil
	} else {
		return "Wrong name/password combination", false, nil //password mismatch
	}
}

func (d USERDB) Profile(name string, token string) (any, bool) {
	userSession := d.CheckToken(name, token)
	if userSession {
		userData := entities.UserDB{}
		userData, check, err := d.CheckUserExist(name)
		if err != nil {
			return "Fail", false //db fail
		}
		if check {
			return userData, true //if there is token it will not fail
		}
	}
	return "Fail", false //jwt token fail
}

func (d USERDB) UpdateProfile(name string, password string, newPassword string, email string, dob *string, gender *string, token string) (string, bool) {
	userSession := d.CheckToken(name, token)
	if userSession {
		userData := entities.UserDB{}
		userData, check, err := d.CheckUserExist(name)
		if err != nil {
			return "Fail", false
		}
		if check {
			if CheckPasswordHash(password, userData.Password) {
				if newPassword != "" {
					return d.UpdateAll(newPassword, email, dob, gender, name)
				} else {
					return d.UpdateEmail(email, dob, gender, name)
				}
			} else {
				return "Wrong current password", false
			}
		}
	}
	return "Fail", false //jwt token fail
}

func (d USERDB) Logout(name string, token string) (string, bool) {
	userSession := d.CheckToken(name, token)
	if userSession {
		_, check, err := d.CheckUserExist(name)
		if err != nil {
			return "Fail", false
		}
		if check {
			_, logoutErr := d.Db.Query(logoutSQL, token)
			if logoutErr != nil {
				return "Fail", false
			}
			return "Successfully", true
		}
	}
	return "Fail", false
}
