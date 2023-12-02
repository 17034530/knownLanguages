function checkSession() {
  const token  = sessionStorage.getItem("token")

  if(token){
    var name = sessionStorage.getItem("name")
    var data = {
      name: name,
      token: token
    }
    
    $.ajax({
      type: "POST",
      url: "http://localhost/php/profile.php",
      data: JSON.stringify(data),
      cache: false,
      dataType: "JSON",
      success: function (res) {
        if(res.check){
          const dataName = res.result["name"]
          if(name && dataName.toLowerCase() === name.toLowerCase() && !(dataName === name)){
            sessionStorage.setItem("name", dataName)
            name = dataName
          }
        }
        checkurl(res.check)
      },
      error: function (obj, textStatus, errorThrown) {
        console.log("Error " + textStatus + ": " + errorThrown)
      }
    })
  }
  else{
    checkurl(false) 
  }
}

function checkurl(islogin){
  if(islogin){
    if(window.location.href != "/home.html" 
    && window.location.href != "/profile.html"){
      window.location.href = "/home.html"
    }
  }else{
    if(window.location.href != "/login.html" 
    && window.location.href != "/create.html"){
      window.location.href = "/login.html"
    }
  }
}

$(document).ready(function() {
  checkSession()
});