<script>
  import { Router, Route } from "svelte-routing";

	import Loading from "./components/Loading.svelte";
	import NotFound from "./components/NotFound.svelte";

	import Login from "./components/login.svelte";
  import Create from "./components/Create.svelte";

  import Home from "./components/Home.svelte";
	import Profile from "./components/Profile.svelte";
  import Setting from "./components/Setting.svelte";

  let loaded = true
	let loggedIn = false

	let ipaddress = "localhost"
	let port = "3000"
	let backendlink = `http://${ipaddress}:${port}/`

	let token = sessionStorage.getItem("token")
	let name = sessionStorage.getItem("name")

	function userAuth() {
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
			const dataName = data.result[0]["name"]
			if(name && dataName.toLowerCase() === name.toLowerCase() && !(dataName === name)){
				sessionStorage.setItem("name", dataName)
				name = dataName
			}
			loggedIn = data.check
			loaded = true
		})
		.catch((err) =>{
      console.log(err)
			loaded = true
    })
	}
	
	if(token){
		loaded = false
		userAuth()
	}

	function handleIP(event){
    ipaddress = event.detail["ipaddress"]
		port = event.detail["port"]
		backendlink = event.detail["backendlink"]
  }

</script>


<Router>
	{#if loaded}
		{#if loggedIn}
			<Route path={"/"}>
				<Home backendlink={backendlink} />
			</Route>
			<Route path={"/profile"}>
				<Profile backendlink={backendlink} />
			</Route>
			<Route component={NotFound} />

		{:else}
			<Route path={"/"}>
				<Login backendlink={backendlink}/>
			</Route>
			<Route path={"/create"}>
				<Create backendlink={backendlink}/>
			</Route>
			<Route path={"/setting"}>
				<Setting on:ipChange={handleIP}/>
			</Route>
			<Route component={NotFound} />
		{/if}
	
	{:else}
		<Route component={Loading} />
	{/if}
</Router>

