<script>
  export let backendlink = ""

  let name
  let password 
  let email
  let dob
  let gender = ""

  function createForm(){
    try{
      fetch(backendlink+"createUser", {
        method: "POST",
        headers: {
        'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          name: name,
          password: password,
          email: email,
          dob: dob,
          gender: gender 
        })
      })
      .then(response => response.json())
      .then(data => {
        alert(data.result)
        if(data.check){
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
              window.location.href = "/"
            }
          })
          .catch((err) =>{
            console.log(err)
            alert("TRY AGAIN LATER")
          })
        }
      })
      .catch((err) =>{
        console.log(err)
        alert("TRY AGAIN LATER")
      })
    }catch(err){
      console.log(err)
      alert("TRY AGAIN LATER")
    }
  }
  
</script>


<main>
  <div class="centerDiv">
    <span class="forTitle" for="">Create account</span>
    <form on:submit|preventDefault={createForm} class="info">
      <div class="form-group">
        <label for="name" class="text-muted mb-1">
          Name:
        </label>
        <input on:change={(e) => name = e.target.value} id="name" name="name" class="form-control" type="text" placeholder="Name" autoComplete="off" required/>
        </div>
        <div class="form-group">
        <label for="password" class="text-muted mb-1">
          Password:
        </label>
        <input on:change={(e) => password = e.target.value} id="password" name="password" class="form-control" type="password" placeholder="Password" required/>
      </div>

      <div class="form-group">
        <label for="email" class="text-muted mb-1">
          Email:
        </label>
        <input on:change={(e) => email = e.target.value} id="email" name="email" class="form-control" type="text" placeholder="Email" required/>
      </div>

      <div class="form-group">
        <label for="dob" class="text-muted mb-1">
          Dob:
        </label>
        <input on:change={(e) => dob = e.target.value } id="dob" name="dob" class="form-control" type="date" placeholder="Dob" />
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
        Create
      </button>

    </form>
  </div>
</main>