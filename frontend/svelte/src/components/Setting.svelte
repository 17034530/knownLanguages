<script>
  import RightNav from "./RightNav.svelte"
  import {navigate} from "svelte-routing";
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();
  
  let backendlink
  let ipaddress
  let port
  
  function ipForm(){
    if(ipaddress && port){
      backendlink = `http://${ipaddress}:${port}/`

      alert(`Your new IP address is ${ipaddress} and port is ${port}`)
      dispatch('ipChange', {ipaddress, port, backendlink});
      navigate("/")
      
    }else{
      alert("Ip address or Port cannot be empty")
    }
  }

</script>

<main>
  <RightNav page="setting" />
  <div class="centerDiv">
    <span>IP Setting</span>
    <form on:submit|preventDefault={ipForm} class="info">
      <div class="form-group">
        <label for="ipa" class="text-muted mb-1">
          IP setting:
        </label>
        <input on:change={(e) => ipaddress = e.target.value} id="ipa" name="ipa" class="form-control" type="text" autoComplete="off" />
      </div>
      <div class="form-group">
        <label for="port" class="text-muted mb-1">
          Port:
        </label>
        <input on:change={(e) => port = e.target.value} id="port" name="port" class="form-control" type="text" autoComplete="off" />
      </div>
      <button type="submit" class="formButton py-3 mt-4 btn btn-lg btn-success btn-block">
        Update
      </button>
    </form>
  </div>
</main>