function logout(){
  const token  = sessionStorage.getItem("token")
  if(token){
    var name = sessionStorage.getItem("name")
    var data = {
      name: name,
      token: token
    }
    
    $.ajax({
      type: "DELETE",
      url: "http://localhost/php/logout.php",
      data: JSON.stringify(data),
      cache: false,
      dataType: "JSON",
      success: function (res) {
        if(res.check){
          sessionStorage.clear()
          window.location.href = "/login.html"
        }else{
          window.location.href = "/login.html"
        }
      },
      error: function (obj, textStatus, errorThrown) {
        console.log("Error " + textStatus + ": " + errorThrown)
      }
    })
  }else{
    window.location.href = "/login.html"
  }
}

function changePage(page){
  window.location.href = `${page}.html`
}
