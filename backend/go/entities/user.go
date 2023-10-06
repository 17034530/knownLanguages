package entities

// import "github.com/golang-jwt/jwt"

type Users struct {
	Name     string `json:"name"`
	Password string `json:"password"`
	Email    string `json:"email"`
	Dob      string `json:"dob"`
	Gender   string `json:"gender"`
}

type UserDB struct {
	Name     string  `json:"name"`
	Password string  `json:"password"`
	Email    string  `json:"email"`
	Dob      *string `json:"dob"`
	Gender   *string `json:"gender"`
	Doc      string
}

type UserToken struct {
	Name     string `json:"name"`
	Password string `json:"password"`
	Email    string `json:"email"`
	Dob      string `json:"dob"`
	Gender   string `json:"gender"`
	Token    string `json:"token"`
}

type UserLogin struct {
	Name     string `json:"name"`
	Password string `json:"password"`
	Device   string `json:"device"`
}

type UserUpdate struct {
	Name        string `json:"name"`
	Password    string `json:"password"`
	NewPassword string `json:"newPassword"`
	Email       string `json:"email"`
	Dob         string `json:"dob"`
	Gender      string `json:"gender"`
	Token       string `json:"token"`
}
