function getProfile(){
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
          $("#titleName").text(res.result["name"])
          $("#email").val(res.result["email"])
          if(res.result["DOB"] !== null){
            let DOBDate = new Date(res.result["DOB"])
            let formatDate = `${DOBDate.getFullYear()}-${("0" + (DOBDate.getMonth() + 1)).slice(-2)}-${("0" + DOBDate.getDate()).slice(-2)}`
    
            $("#dob").val(formatDate)

          }
          $("#gender").val(res.result["gender"])


        }else{

        }
      },
      error: function (obj, textStatus, errorThrown) {
        console.log("Error " + textStatus + ": " + errorThrown)
      }
    })
  }
}

function emptyform(){
  $("#password").val("")
  $("#newPassword").val("")
  
}

$(document).ready(function(){
  getProfile()

  $("form").submit(function(){
    const token = sessionStorage.getItem("token")
    var name = sessionStorage.getItem("name")
    var password = $("#password").val()
    var newPassword = $("#newPassword").val()
    var email = $("#email").val()
    var dob = $("#dob").val()
    var gender = $("#gender").val()

    var data = { 
      name: name, 
      password: password, 
      newPassword: newPassword,
      email: email,
      dob: dob,
      gender, gender,
      token: token
    }

    $.ajax({
      type: "PATCH",
      url: "http://localhost/php/updateProfile.php",
      data: JSON.stringify(data),
      cache: false,
      dataType: "JSON",
      success: function (res) {
        alert(res.result)
        emptyform()
      },
      error: function (obj, textStatus, errorThrown) {
        console.log("Error " + textStatus + ": " + errorThrown)
      }
    })
    return false

  })
})