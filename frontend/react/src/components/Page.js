import React, { useEffect } from "react"
import Container from "./Container"

function Page(props) {
  useEffect(() => {
    if (props.title === "") {
      document.title = `React`
    } else {
      document.title = `${props.title} | React`
    }
    window.scrollTo(0, 0)
  }, [props.title])

  return <Container wide={props.wide}>{props.children}</Container>
}

export default Page
