<script>
  import { onMount } from "svelte";
  import RightNav from "./RightNav.svelte";
  
  export let backendlink = ""
  let name = sessionStorage.getItem("name")
  let token = sessionStorage.getItem("token")

  let password = ""
  let newPassword = ""
  let email
  let dob = ""
  let gender = ""

  onMount(() => { 
    fetch(backendlink+"profile", {
      method: "POST",
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
        const result = data.result[0]
        email = result["email"]

        if(result["DOB"] != null){
          let DOBDate = new Date(result["DOB"])
          dob = `${DOBDate.getFullYear()}-${("0" + (DOBDate.getMonth() + 1)).slice(-2)}-${("0" + DOBDate.getDate()).slice(-2)}`
        }
      }
    })
    .catch((err) =>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  })


  function emptyForm(){
    password = ""
    newPassword = ""
  }
  

  function editForm(){
    fetch(backendlink+"updateProfile", {
      method: "PATCH",
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: name,
        password: password,
        newPassword, newPassword,
        email: email,
        dob: dob,
        gender: gender,
        token: token
      })
    })
    .then(response => response.json())
    .then(data => { 
      alert(data.result)
      emptyForm()
    })
    .catch((err) =>{
      console.log(err)
      alert("TRY AGAIN LATER")
    })
  }
</script>

<main>
  <RightNav backendlink={backendlink} page="profile" />
  <div class="centerDiv">
    <h1>{name}</h1>
    <form on:submit|preventDefault={editForm} class="info">

    <div class="form-group">
      <label  for="password"  class="text-muted mb-1">
        Password:
      </label>
      <input value={password} on:change={(e) => password = e.target.value} id="password" name="password" class="form-control" type="password" placeholder="Password" required/>
    </div>

    <div class="form-group">
      <label for="newPassword" class="text-muted mb-1">
        New Password:
      </label>
      <input value={newPassword} on:change={(e) => newPassword = e.target.value} id="newPassword" name="newPassword" class="form-control" type="password" placeholder="New Password"/>
    </div>

    <div class="form-group">
        <label for="email" class="text-muted mb-1">
          Email:
        </label>
        <input value={email} on:change={(e) => email = e.target.value} id="email" name="email" class="form-control" type="text" placeholder="Email" required /> 
      </div>

      <div class="form-group">
        <label for="dob" class="text-muted mb-1">
          Dob:
        </label>
        <input value={dob} on:change={(e) => dob = e.target.value} id="dob" name="dob" class="form-control" type="date" placeholder="Dob" />
      </div>

      <div class="form-group">
        <label for="gender" class="text-muted mb-1">
          Gender:
        </label>
        <select value={gender} on:change={e => gender = e.target.value} id="gender" name="gender">
          <option value="">Prefer not to say</option>
          <option value="Male">Male</option>
          <option value="Female">Female</option>
          <option value="Others">Others</option>
        </select>
      </div>
      <button type="submit" class="formButton py-3 mt-4 btn btn-lg btn-success btn-block">
        Update
      </button>
    </form>
  </div>
</main>