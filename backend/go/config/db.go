package config

import (
	"database/sql"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

func GetMySQLDB() (db *sql.DB, err error) {

	cfg := godotenv.Load("config/config.env")
	if cfg != nil {
		return db, cfg
	}
	dbDriver := os.Getenv("DBDRIVER")
	dbUser := os.Getenv("DBUSER")
	dbPass := os.Getenv("PASSWORD")
	dbName := os.Getenv("DATABASE")
	dbPort := os.Getenv("DBPORT")
	db, err = sql.Open(dbDriver, dbUser+":"+dbPass+"@tcp(127.0.0.1:"+dbPort+")/"+dbName)
	return db, err
}
