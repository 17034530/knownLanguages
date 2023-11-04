import React, { useState } from "react"
import Page from "./Page"
import RightNav from "./RightNav"
import { useNavigate } from "react-router-dom"


function Setting(props){
  const [ipad, setIpAd] = useState("")
  const [ipPort, setIPPort] = useState("")

  const nav = useNavigate()

  function ipForm(e){
    e.preventDefault()
    if(ipad && ipPort){
      props.setApi(ipad)
      props.setPort(ipPort)
      alert(`Your new IP address is ${ipad} and port is ${ipPort}`)
      nav("/")
    }else{
      alert("Ip address or Port cannot be empty")
    }
  }

  return (
    <Page wid={true} title="">
      <RightNav page={'setting'}/>
      <div className="centerDiv">
        <span>IP Setting</span>
        <form onSubmit={ipForm} className="info">
          <div className="form-group">
            <label htmlFor="ipa" className="text-muted mb-1">
              IP setting:
            </label>
            <input onChange={(e) => setIpAd(e.target.value)} id="ipa" name="ipa" className="form-control" type="text" autoComplete="off" />
          </div>
          <div className="form-group">
            <label htmlFor="port" className="text-muted mb-1">
              Port:
            </label>
            <input onChange={(e) => setIPPort(e.target.value)} id="port" name="port" className="form-control" type="text" autoComplete="off" />
          </div>
          <button type="submit" className="formButton py-3 mt-4 btn btn-lg btn-success btn-block">
            Update
          </button>
        </form>
      </div>
    </Page>
  )
}

export default Setting