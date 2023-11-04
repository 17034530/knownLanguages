import React, { useState } from "react"
import Page from "./Page"
import Axios from "axios" //to help send of request
import { useNavigate } from "react-router-dom"

function Create(props) {
  const [name, setName] = useState("")
  const [password, setPassword] = useState("")
  const [email, setEmail] = useState("")
  const [dob, setDob] = useState("")
  const [gender, setGender] = useState("")

  const nav = useNavigate()

  function emptyForm(){
    setName("")
    setPassword("")
    setEmail("")
    setDob("")
    setGender("")
  }

  function createForm(e) {
    e.preventDefault()
    Axios.post(props.backendlink + "createUser", {name, password, email, dob, gender})
    .then((res)=> {
      alert(res.data.result)
      if(res.data.check){
        Axios.post(props.backendlink + "login", { name, password, device: "react" }) //unable to get device info
        .then((reslogin)=>{
          if (!reslogin.data.check) {
            alert(reslogin.data.result)
            emptyForm()
          } else {
            sessionStorage.setItem("token", reslogin.data.token)
            sessionStorage.setItem("name",name)

            props.setToken(sessionStorage.getItem("token"))
            nav("/")
          }
        })
        .catch((err) =>{
          console.log(err)
          alert("TRY AGAIN LATER")
        })
      }
    })
    .catch((err)=>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  }


  return (
    <Page wid={true} title="">
      <div className="centerDiv">
        <span>Create account</span>
        <form onSubmit={createForm} className="info">
          <div className="form-group">
            <label htmlFor="name" className="text-muted mb-1">
              Name:
            </label>
            <input onChange={(e) => setName(e.target.value)} id="name" name="name" className="form-control" type="text" autoComplete="off" required/>
            </div>
            <div className="form-group">
            <label htmlFor="password" className="text-muted mb-1">
              Password:
            </label>
            <input onChange={(e) => setPassword(e.target.value)} id="password" name="password" className="form-control" type="password" required/>
          </div>

          <div className="form-group">
            <label htmlFor="email" className="text-muted mb-1">
              Email:
            </label>
            <input onChange={(e) => setEmail(e.target.value)} id="email" name="email" className="form-control" type="text" required/>
          </div>

          <div className="form-group">
            <label htmlFor="dob" className="text-muted mb-1">
              Dob:
            </label>
            <input onChange={(e) => setDob(e.target.value)} id="dob" name="dob" className="form-control" type="date"/>
          </div>

          <div className="form-group">
            <label htmlFor="gender" className="text-muted mb-1">
              Gender:
            </label>
            <select value={gender} onChange={e => setGender(e.target.value)} id="gender" name="gender" className="form-control">
              <option value="">Prefer not to say</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
              <option value="Others">Others</option>
            </select>
          </div>

          <button type="submit" className="formButton py-3 mt-4 btn btn-lg btn-success btn-block">
            Create
          </button>

        </form>
      </div>
    </Page>
  )
}

export default Create