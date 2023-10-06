package routes

import (
	"myModule/controllers"

	"github.com/gorilla/mux"
)

func UserRouter(r *mux.Router) {
	r.HandleFunc("/createUser", controllers.CreateUser).Methods("POST")
	r.HandleFunc("/login", controllers.Login).Methods("POST")
	r.HandleFunc("/profile", controllers.Profile).Methods("POST")
	r.HandleFunc("/updateProfile", controllers.UpdateProfile).Methods("PATCH")
	r.HandleFunc("/logout", controllers.Logout).Methods("DELETE")
}
