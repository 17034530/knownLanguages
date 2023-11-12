import { IconButton } from '@mui/material'
import LoginIcon from '@mui/icons-material/Login';
import SettingIcon from '@mui/icons-material/Settings'
import PersonIcon from '@mui/icons-material/Person'
import HomeIcon from '@mui/icons-material/Home';
import { useNavigate } from "react-router-dom"
import { useState } from "react"
import Axios from "axios"

function RightNav(props){
  const [name,] = useState(sessionStorage.getItem("name"))
  const [token,] = useState(sessionStorage.getItem("token"))
  const [page,] = useState(props.page)
  const nav = useNavigate()
  
  function logout(){
    Axios.delete(props.backendlink + "logout",{ data: {name, token}} )
    .then((res) => {
      sessionStorage.clear()
      //instead of window.location.reload() in case not at homepage
      //using nav required to pass props like url over
      window.location.assign("/") 
    })
    .catch((err)=>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  }
  
  function navTo(){
    if(page === "login"){
      nav("/setting")
    }else if(page === "home"){
      nav('/profile')
    }else{
      nav("/")
    }
  }

  return(
    <div className="rightContainer">
      <IconButton aria-label="delete" size="large" onClick={navTo} className="button">
        {page === "login" ? <SettingIcon fontSize="inherit" /> 
          : page === "setting" ? <LoginIcon fontSize="inherit" /> 
          :  page === "home" ?  <PersonIcon fontSize="inherit" />
          : <HomeIcon fontSize="inherit" />
        }
      </IconButton>
      {page === "home" || page === "profile" ? 
        <button type="button" onClick={logout} className="button">
          Logout
        </button> 
        : <></>
      }
    </div>
  )
}

export default RightNav