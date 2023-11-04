import { useEffect, useState } from "react"
import Page from "./Page"
import RightNav from "./RightNav"
import Axios from "axios"

function Profile(props){
  const [name, ] = useState(sessionStorage.getItem("name"))
  const [token, ] = useState(sessionStorage.getItem("token"))

  const [password, setPassword] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [email, setEmail] = useState("")
  const [dob, setDob] = useState("")
  const [gender, setGender] = useState("")

  useEffect(()=>{
    Axios.post(props.backendlink + "profile", { name, token })
    .then((res) => {
      const result = res.data.result[0]
      setEmail(result["email"])
      if(result["DOB"] !== null){
        let DOBDate = new Date(result["DOB"])
        let formatDate = `${DOBDate.getFullYear()}-${("0" + (DOBDate.getMonth() + 1)).slice(-2)}-${("0" + DOBDate.getDate()).slice(-2)}`

        setDob(formatDate)
      }
      if(result["gender"] !== null){
        setGender(result["gender"])
      }
    })
    .catch((err) =>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  },[name,token,props.backendlink])

  function emptyForm(pwOnly){
    setPassword("")
    if(!pwOnly){
      setNewPassword("")
    }
  }

  function editForm(e){
    e.preventDefault()
    Axios.patch(props.backendlink + "updateProfile", { name, password, newPassword, email, dob, gender, token })
    .then((res) => {
      alert(res.data.result)
      emptyForm(res.data.check)
    })
    .catch((err) =>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  }

  return (
    <Page wid={true} title="">
      <RightNav page={'profile'} backendlink={props.backendlink}/>
      <div className="centerDiv">
        <h1>{name}</h1>
        <form onSubmit={editForm} className="info">

        <div className="form-group">
          <label htmlFor="password" className="text-muted mb-1">
            Password:
          </label>
          <input value={password} onChange={(e) => setPassword(e.target.value)} id="password" name="password" className="form-control" type="password" required/>
        </div>

        <div className="form-group">
          <label htmlFor="newPassword" className="text-muted mb-1">
            New Password:
          </label>
          <input value={newPassword} onChange={(e) => setNewPassword(e.target.value)} id="newPassword" name="newPassword" className="form-control" type="password"/>
        </div>

        <div className="form-group">
            <label htmlFor="email" className="text-muted mb-1">
              Email:
            </label>
            <input value={email} onChange={(e) => setEmail(e.target.value)} id="email" name="email" className="form-control" type="text" required /> 
          </div>

          <div className="form-group">
            <label htmlFor="dob" className="text-muted mb-1">
              Dob:
            </label>
            <input value={dob} onChange={(e) => setDob(e.target.value)} id="dob" name="dob" className="form-control" type="date" />
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
            Update
          </button>
        </form>
      </div>
    </Page>
  )

}

export default Profile