$(document).ready(function(){

  $("form").submit(function () {
    var name = $("#name").val()
    var password = $("#password").val()

    var data = { 
      name: name, 
      password: password, 
      device: "/test"
    }

    $.ajax({
      type: "POST",
      url: "http://localhost/php/login.php",
      data: JSON.stringify(data),
      cache: false,
      dataType: "JSON",
      success: function (res) {
        if(res.check){
          sessionStorage.setItem("token", res.token)
          sessionStorage.setItem("name",name)
          window.location.href = "/home.html"
        }else{
          alert(res.result)
        }
      },
      error: function (obj, textStatus, errorThrown) {
        console.log("Error " + textStatus + ": " + errorThrown)
      }
    })
    return false
  })

})

function createpage() {
  window.location.href = "file:///Users/tanjunhe/Desktop/backup/frontend/web/html/create.html"
}