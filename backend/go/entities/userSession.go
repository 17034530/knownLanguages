package entities

type UserSession struct {
	Token  string `json:"token"`
	Name   string `json:"name"`
	Device string `json:"device"` //future implication
}
