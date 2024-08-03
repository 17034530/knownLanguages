#include "login.h"
#include "dataController.h"
#include "main.h"
#include "home.h"

using namespace std;

static void handleMenu(bool firstTime); 

static void handleLogin(const char* name, const char* password){
  // Construct JSON data using std::string
  string jsonDataStr = "{\n\"name\":\""+ string(name) + "\",\n\"password\":\"" + string(password) + "\",\n \"device\" :\"exe\"}";
  const char* jsonData = jsonDataStr.c_str();
  
  const string readBuffer = DataControllerC::APICall(jsonData,"login");
  const vector<string> vectorBuffer = DataControllerC::split(readBuffer, ',');
  const vector<string> resultVector = DataControllerC::split(vectorBuffer[0], ':');
  const vector<string> checkVector = DataControllerC::split(vectorBuffer[1], ':');
  if(checkVector[1] == "true"){
    const vector<string> tokenVector = DataControllerC::split(vectorBuffer[2], ':');
    HomeC::Home(name, tokenVector[1].c_str());
  }else{
    cout << resultVector[1] << endl;
    handleMenu(false);
  }
}

void handleMenu(bool firstTime){
  const char* choice = "1";
  do{
    if(!firstTime){
      choice = DataControllerC::get_str_input("Try again (1) or 'q' to return to main menu: ");
    }
    if(strcmp(choice, "1") == 0){
      const char* name = DataControllerC::get_str_input("Enter Username: ");
      const char* password = DataControllerC::get_password_input("Enter Password: ");
      handleLogin(name,password);
    }else if(strcmp(choice, "q") == 0){
      MainC::mainMenu();
    }
  }while(strcmp(choice, "q") != 0);
}

void LoginC::Login(){
  handleMenu(true);
}