<script>
  import {navigate} from "svelte-routing";
  import IconButton, { Icon } from '@smui/icon-button';
  import '@smui/icon-button/*';
  

  export let backendlink = ""
  export let page = ""
  let name = sessionStorage.getItem("name")
  let token = sessionStorage.getItem("token")

  function logout(){
    fetch(backendlink+"logout", {
      method: "DELETE",
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: name,
        token: token
      })
    })
    .then(response => response.json())
    .then(data => {
      if(data.check){
        sessionStorage.clear()
        //instead of window.location.reload() in case not at homepage
        //using nav required to pass props like backendlink over
        window.location.assign("/") 
      }
    })
    .catch((err) =>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  }

  function navTo(){
    if(page === "login"){
      navigate("/setting")
    }else if(page === "home"){
      navigate('/profile')
    }else{
      navigate("/")
    }
  }
</script>

<main>
  <div class="rightContainer" >
    {#if page === "login"}
      <button class="transparent-button" on:click={navTo}>
        <i class="fas fa-cog"></i>
      </button>
    {:else if page === "setting"}
      <button class="transparent-button" on:click={navTo}>
        <i class="fas fa-sign-in-alt"></i>
      </button>
    {:else if page === "home"}
      <button class="transparent-button" on:click={navTo}>
        <i class="fas fa-user"></i>
      </button>
    {:else}
      <button class="transparent-button" on:click={navTo}>
        <i class="fas fa-home"></i>
      </button>
    {/if}

    {#if page === "home" || page === "profile"}
      <button type="button" on:click={logout} class="button">
        Logout
      </button> 
    {/if}
  </div>
</main>