#include "home.h"
#include <iostream>
#include "dataController.h"
#include "main.h"
#include "editprofile.h"

using namespace std;

static const char *gname;
static const char *gtoken;

static void handleViewProfile(){
  // Construct JSON data using std::string
  string jsonDataStr = "{\"name\":\""+ string(gname) + "\", \"token\":\"" + string(gtoken) + "\"}";
  const char* jsonData = jsonDataStr.c_str();

  const string readBuffer = DataControllerC::APICall(jsonData,"profile");
  const vector<string> vectorBuffer = DataControllerC::split(readBuffer, ',');
  const vector<string> checkVector = DataControllerC::split(vectorBuffer[6], ':');
  if(checkVector[1] == "true"){
    const vector<string> nameVector = DataControllerC::split(vectorBuffer[0],':');
    //vectorBuffer[1] = password
    const vector<string> emailVector = DataControllerC::split(vectorBuffer[2], ':');
    const vector<string> dobVector = DataControllerC::split(vectorBuffer[3], ':');
    const vector<string> genderVector = DataControllerC::split(vectorBuffer[4], ':');
    const string formatDate = strcmp(dobVector[1].c_str(),"null") == 0 ? "" : DataControllerC::formatDateSQL(dobVector[1].c_str());
    const string vgender = strcmp(genderVector[1].c_str(),"null") == 0 ? "Prefer not to say" : genderVector[1];
    cout << "Your Profile" << endl;
    cout << "-----------------------------------------------" << endl;
    cout << "name: " << nameVector[1] << endl;
    cout << "email: " << emailVector[1] << endl;
    cout << "DOB(YYYY-MM-DD): " << formatDate.c_str() << endl;
    cout << "Gender: " << vgender << endl;
    cout << "-----------------------------------------------" << endl;
  }else{
    cout << "Try Again Later" << endl;
  }
  HomeC::Home(gname, gtoken);
}

static void handleLogout(){
  // Construct JSON data using std::string
  string jsonDataStr = "{\"name\":\""+ string(gname) + "\", \"token\":\"" + string(gtoken) + "\"}";
  const char* jsonData = jsonDataStr.c_str();

  const string readBuffer = DataControllerC::APICall(jsonData,"logout");
  const vector<string> vectorBuffer = DataControllerC::split(readBuffer, ',');
  const vector<string> resultVector = DataControllerC::split(vectorBuffer[0], ':');
  const vector<string> checkVector = DataControllerC::split(vectorBuffer[1], ':');
  if(vectorBuffer[1] == "true"){
    cout << resultVector[1] << endl;
    MainC::mainMenu();
  }else{
    cout << resultVector[1] << endl;
    MainC::mainMenu();
  }
}

static void displayMenu(){
  cout << "1. View Profile" << endl;
  cout << "2. Edit Profile" << endl;
  cout << "3. Logout" << endl;
  cout << "m. menu" << endl;
}

static void handleMenu(){
  displayMenu();
  const char* choice = DataControllerC::get_str_input("Enter An Option: ");
    do{
      if(strcmp(choice, "1") == 0){
        handleViewProfile();
      }else if(strcmp(choice, "2") == 0){
        EditProfileC::EditProfile(gname, gtoken);
      }else if(strcmp(choice, "3") == 0){
        handleLogout();
      }else if(strcmp(choice, "m") == 0){
        displayMenu();
      }else if(strcmp(choice, "q") == 0){
        cout << "Invalid option" << endl;
      }
    }while(strcmp(choice, "q") != 0);
}

void HomeC::Home(const char *name, const char *token){
  gname = name;
  gtoken = token;
  handleMenu();
}