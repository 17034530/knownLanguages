$(document).ready(function(){

  $("form").submit(function(){
    var name = $("#name").val()
    var password = $("#password").val()
    var email = $("#email").val()
    var dob = $("#dob").val()
    var gender = $("#gender").val()

    var createData = { 
      name: name, 
      password: password, 
      email: email,
      dob: dob,
      gender, gender,
      device: "/test"
    }

    var loginData = { 
      name: name, 
      password: password, 
      device: "/test"
    }

    $.ajax({
      type: "POST",
      url: "http://localhost/php/create.php",
      data: JSON.stringify(createData),
      cache: false,
      dataType: "JSON",
      success: function (createRes) {
        alert(createRes.result)
        if(createRes.check){
          $.ajax({
            type: "POST",
            url: "http://localhost/php/login.php",
            data: JSON.stringify(loginData),
            cache: false,
            dataType: "JSON",
            success: function (loginRes) {
              if(loginRes.check){
                sessionStorage.setItem("token", loginRes.token)
                sessionStorage.setItem("name",name)
                window.location.href = "/home.html"
              }else{
                alert(loginRes.result)
              }
            },
            error: function (obj, textStatus, errorThrown) {
              console.log("Error " + textStatus + ": " + errorThrown)
            }
          })
        }
      },
      error: function (obj, textStatus, errorThrown) {
        console.log("Error " + textStatus + ": " + errorThrown)
      }
    })
    return false
  })
})

