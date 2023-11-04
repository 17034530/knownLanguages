import Page from "./Page"
import RightNav from './RightNav'

function Home(props){

  return(
    <Page wid={true} title="">
      <RightNav page={'home'} backendlink={props.backendlink}/>
      <div className="centerDiv">
      
      </div>
    </Page>
  )
}

export default Home