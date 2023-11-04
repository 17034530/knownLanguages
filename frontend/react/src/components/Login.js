import React, { useState } from "react"
import Page from "./Page"
import Axios from "axios" //to help send of request
import { useNavigate } from "react-router-dom"
import RightNav from "./RightNav"

function Login(props) {
  const [name, setName] = useState("")
  const [password, setPassword] = useState("")

  const nav = useNavigate()

  function loginForm(e) {
    e.preventDefault()
    Axios.post(props.backendlink + "login", { name, password, device:"react" }) //unable to get device info
    .then((res)=>{
      if (!res.data.check) {
        alert(res.data.result)
      } else {
        sessionStorage.setItem("token", res.data.token)
        sessionStorage.setItem("name",name)
        props.setToken(sessionStorage.getItem("token"))
        nav("/")
      }
    })
    .catch((err)=>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  }

  function createForm(){
    nav("/create")
  }

  return (
    <Page wid={true} title="">
      <RightNav page={'login'} backendlink={props.backendlink}/>
      <div className="centerDiv">
        <span>Login</span>
        <form onSubmit={loginForm} className="info">
          <div className="form-group">
            <label htmlFor="name" className="text-muted mb-1">
              Name:
            </label>
            <input onChange={(e) => setName(e.target.value)} id="name" name="name" className="form-control" type="text" autoComplete="off" />
          </div>
          <div className="form-group">
            <label htmlFor="password" className="text-muted mb-1">
              Password:
            </label>
            <input onChange={(e) => setPassword(e.target.value)} id="password" name="password" className="form-control" type="password" />
          </div>
          <button type="submit" className="formButton2 py-3 mt-4 btn btn-lg btn-success btn-block">
            Login
          </button>
          <button type="button" onClick={createForm} className="formButton2 py-3 mt-4 btn btn-lg btn-success btn-block">
            Sign Up
          </button> 
        </form>
      </div>
    </Page>
  )
}

export default Login
