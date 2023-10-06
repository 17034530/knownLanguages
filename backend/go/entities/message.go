package entities

type Msg struct {
	Result string `json:"result"`
	Check  bool   `json:"check"`
}

type LoginMsg struct {
	Result string `json:"result"`
	Check  bool   `json:"check"`
	Token  string `json:"token"`
}

type ProfileMsg struct {
	Result any  `json:"result"`
	Check  bool `json:"check"`
}
