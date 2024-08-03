#include "editprofile.h"
#include "dataController.h"
#include "home.h"

using namespace std;

static const char *gname;
static const char *gtoken;
static const char *gemail;
static const char *gdob;
static const char *ggender;

static void handleCreate(const char* name, const char* password,const char* newpassword ,const char* email, const char* dob, const char* gender, const char* token){
  string jsonDataStr = "{\n \"name\":\""+string(name)+"\",\n\"password\":\""+string(password)
                    +"\",\n\"newPassword\":\""+string(newpassword)+"\",\n\"email\":\""+string(email)+
                    "\",\n\"dob\":\""+string(dob)+"\",\n \"gender\":\""+string(gender)+
                    "\",\n\"token\":\""+string(token)+"\"\n}";
  const char* jsonData = jsonDataStr.c_str();
  const string readBuffer = DataControllerC::APICall(jsonData, "updateProfile");
  const vector<string> vectorBuffer = DataControllerC::split(readBuffer, ',');
  const vector<string> resultVector = DataControllerC::split(vectorBuffer[0], ':');
  cout << resultVector[1] << endl;
  HomeC::Home(name,token);
}

static const char* handleChangePassword(){
  const char* bpassword = DataControllerC::get_str_input("Change Password? (Y/N): ");
  if(strcmp(bpassword, "Y") == 0){
    const char* newPassword = DataControllerC::get_password_input("Enter New Password: ");
    return newPassword;
  }else if(strcmp(bpassword, "N") == 0) { 
    return "";
  }else{
    cout << "Invaild Option. System will take it as No" << endl;
    return "";
  }
}

static const char* handleChangeEmail(){
  const char* bemail = DataControllerC::get_str_input("Change Email? (Y/N): ");
  if(strcmp(bemail, "Y") == 0){
    const char* newEmail = DataControllerC::get_str_input("Enter New Email: ");
    return newEmail;
  }else if(strcmp(bemail, "N") == 0) { 
    return gemail;
  }else{
    cout << "Invaild Option. System will take it as No" << endl;
    return gemail;
  }
}

static const char* handleChangeDOB(){
  const char* bdob = DataControllerC::get_str_input("Change DOB? (Y/N): ");
  if(strcmp(bdob, "Y") == 0){
    const char* newDob = DataControllerC::get_str_input("Enter new Dob (Format: YYYY-MM-DD, e.g: 1970-01-01) ('d' to delete): ");
    if(strcmp(newDob, "d") == 0){
      return "";
    }
    return newDob;
  }else if(strcmp(bdob, "N") == 0) { 
    return gdob;
  }else{
    cout << "Invaild Option. System will take it as No" << endl;
    return gdob;
  }
}

static const char* handleGender(const char* gender){
  if(strcmp(gender, "1") == 0){
    return "";
  }else if(strcmp(gender, "2") == 0){
    return "Male";
  }else if(strcmp(gender, "3") == 0){
    return "Female";
  }else{ //4
    return "Others";
  }
}

static const char* handleChangeGender(){
  const char* bgender = DataControllerC::get_str_input("Change Gender? (Y/N): ");
  if(strcmp(bgender, "Y") == 0){
    const char* newGender = DataControllerC::get_str_input("Enter Gender (1. Prefer not to say, 2. Male, 3. Female, 4. Others): ");
    return handleGender(newGender);
  }else if(strcmp(bgender, "N") == 0) { 
    if(strcmp(ggender,"null") == 0){
      return "";
    }
    return ggender;
  }else{
    cout << "Invaild Option. System will take it as No" << endl;
    if(strcmp(ggender,"null") == 0){
      return "";
    }
    return ggender;
  }
}

static void handleEditProfile(){
  cout << "Name: " << gname <<endl;

  const char* password = DataControllerC::get_password_input("Enter Current Password: ");
  const char* newPassword = handleChangePassword();

  cout << "Current Email: " << gemail << endl;
  gemail = handleChangeEmail();

  cout << "Current DOB(YYYY-MM-DD): " << gdob << endl;
  gdob = handleChangeDOB();

  const string vgender = strcmp(ggender,"null") == 0 ? "Prefer not to say" : ggender;
  cout << "Current Gender: " << vgender << endl;
  ggender = handleChangeGender();
  handleCreate(gname,password, newPassword, gemail, gdob, ggender, gtoken);
}

static void handleViewProfile(){
  string jsonDataStr = "{\"name\":\""+ string(gname) + "\", \"token\":\"" + string(gtoken) + "\"}";
  const char* jsonData = jsonDataStr.c_str();

  const string readBuffer = DataControllerC::APICall(jsonData,"profile");
  const vector<string> vectorBuffer = DataControllerC::split(readBuffer, ',');
  const vector<string> checkVector = DataControllerC::split(vectorBuffer[6], ':');
  if(checkVector[1] == "true"){
    //vectorBuffer[0] = name
    //vectorBuffer[1] = password
    const vector<string> emailVector = DataControllerC::split(vectorBuffer[2], ':');
    const vector<string> dobVector = DataControllerC::split(vectorBuffer[3], ':');
    const vector<string> genderVector = DataControllerC::split(vectorBuffer[4], ':');

    gemail = emailVector[1].c_str();
    gdob =  strcmp(dobVector[1].c_str(),"null") == 0 ? "" : DataControllerC::formatDateSQL(dobVector[1].c_str()).c_str();
    ggender =genderVector[1].c_str();
    handleEditProfile();

  }else{
    cout << "Try Again Later" << endl;
  }
}



void EditProfileC::EditProfile(const char *name, const char *token){
  gname = name;
  gtoken = token;

  handleViewProfile();
}