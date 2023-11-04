import './App.css';
import React, { useState, useEffect } from "react"
import { BrowserRouter , Routes, Route} from "react-router-dom" //to nav -- 
import Axios from "axios"

import Login from "./components/Login"
import Setting from "./components/Setting"
import Create from "./components/Create"
import Home from "./components/Home"
import Profile from "./components/Profile"
import NotFound from './components/NotFound'
import Loading from './components/Loading'

function App() {
  const [ipa, setApi] = useState("localhost")
  const [port, setPort] = useState("3000")
  const backendlink = `http://${ipa}:${port}/`
  const [loggedIn, setLoggedIn] = useState(false)
  const [name, setName] = useState(sessionStorage.getItem("name"))
  const [token, setToken] = useState(sessionStorage.getItem("token"))
  const [loaded, isloaded] = useState(false)

  useEffect(()=>{
    if(token){
      setName(sessionStorage.getItem("name"))
    }else{
      setName("")
      isloaded(true)
    }
  },[token])

  function userAuth() {
    Axios.post(backendlink + "profile", { name, token })
    .then((res) => {
      
      const dataName = res.data.result[0]["name"]
      if(name && dataName.toLowerCase() === name.toLowerCase() && !(dataName === name)){
        sessionStorage.setItem("name", dataName)
        setName(dataName)
      }

      setLoggedIn(res.data.check)
      isloaded(true)
    })
    .catch((err)=>{
      console.log(err)
      isloaded(true)
    })
  }

  if (token) {
    userAuth()
  }

  return (
    <BrowserRouter>
      { loaded ? 
        loggedIn ? 
        (
          <Routes>
            <Route exact path="/" element={<Home backendlink={backendlink}/>} />
            <Route exact path="/profile" element={<Profile backendlink={backendlink} />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        ) : (
          <Routes>
            <Route exact path="/"  element={<Login backendlink={backendlink} setToken={setToken}/>} />
            <Route exact path='/create' element={<Create backendlink={backendlink} setToken={setToken}/>} />
            <Route exact path="/setting" element={<Setting setApi={setApi} setPort={setPort}/> } />
            <Route path="*" element={<NotFound />} />
          </Routes>
        ) : (
          <Routes>
            <Route path="*" element={<Loading/>} />
          </Routes>
        )
      }
    </BrowserRouter>
  );
}

export default App;
