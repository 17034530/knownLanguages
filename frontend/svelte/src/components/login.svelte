<script>
  import {navigate} from "svelte-routing"
  import RightNav from "./RightNav.svelte"

  export let backendlink = ""
  let name 
  let password

  function loginForm() {
    fetch(backendlink + "login", {
      method: "POST",
      headers: {       
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: name,
        password: password,
        device: "tester"
      })
    })
    .then(response => response.json())
    .then(data => {
      if(data.check){
        sessionStorage.setItem("token", data.token)
        sessionStorage.setItem("name",name)
        window.location.reload()
      }else{
        alert(data.result)
      }
      })
      .catch((err) =>{
        console.log(err)
        alert("TRY AGAIN LATER")
      })
  }

  function createForm(){
    navigate("/create")
  }

</script>

<main>
  <RightNav backendlink={backendlink} page="login" />
  <div class="centerDiv">
    <span>Login</span>
    <form on:submit|preventDefault={loginForm} class="info">
      <div class="form-group">
        <label for="name" class="text-muted mb-1">
          Name:
        </label>
        <input on:change={(e) => {name = e.target.value}} id="name" name="name" class="form-control" type="text" placeholder="Name" autoComplete="off" />
        </div>
      <div class="form-group">
        <label for="password" class="text-muted mb-1">
          Password:
        </label>
        <input on:change={(e) => {password = e.target.value}} id="password" name="password" class="form-control" type="password" placeholder="Password" />
      </div>
      <button type="submit" class="formButton2 py-3 mt-4 btn btn-lg btn-success btn-block">
        Login
      </button>
      <button type="button" class="formButton2 py-3 mt-4 btn btn-lg btn-success btn-block" on:click={createForm}>
        Sign Up
      </button> 
      
    </form>
  </div>
</main>

<style>

</style>

