package controllers

import (
	"database/sql"
	"encoding/json"
	"myModule/config"
	"myModule/entities"
	"net/http"
)

type Msg1 struct {
	result string
	check  bool
}

func WriteJsonMsg(res http.ResponseWriter, result string, check bool) {
	message := entities.Msg{
		Result: result,
		Check:  check,
	}
	res.Header().Set("Content-Type", "application/json")
	json.NewEncoder(res).Encode(message)
}

func ConnectDB(res http.ResponseWriter) (*sql.DB, error) {
	db, err := config.GetMySQLDB()
	if err != nil {
		WriteJsonMsg(res, "Try again later", false)
		return nil, err
	}
	return db, nil
}

func WriteJsonLoginMsg(res http.ResponseWriter, result string, check bool, token string) {
	message := entities.LoginMsg{
		Result: result,
		Check:  check,
		Token:  token,
	}
	res.Header().Set("Content-Type", "application/json")
	json.NewEncoder(res).Encode(message)
}

func WriteJsonProfileMsg(res http.ResponseWriter, result any, check bool) {
	message := entities.ProfileMsg{
		Result: result,
		Check:  check,
	}
	res.Header().Set("Content-Type", "application/json")
	json.NewEncoder(res).Encode(message)
}
