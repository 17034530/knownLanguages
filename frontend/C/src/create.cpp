#include "create.h"
#include "dataController.h"
#include "main.h"
#include "home.h"

static void handleMenu(bool firstTime); 

static void handleCreate(const char* name, const char* password, const char* email, const char* dob, const char* gender){
  string createJsonDataStr = "{\n\"name\":\""+ string(name) + "\",\n\"password\":\""+ string(password)
                            +"\",\n\"email\":\""+ string(email)+"\",\n \"dob\":\""+string(dob)
                            +"\",\n \"gender\":\""+string(gender)+"\"\n}";
  const char* createJsonData = createJsonDataStr.c_str();
  const string createReadBuffer = DataControllerC::APICall(createJsonData, "createUser");
  const vector<string> createVectorBuffer = DataControllerC::split(createReadBuffer, ',');
  const vector<string> createResultBuffer = DataControllerC::split(createVectorBuffer[0], ':');
  const vector<string> createCheckVector = DataControllerC::split(createVectorBuffer[1], ':');
  
  if(createCheckVector[1] == "true"){
    cout << "Successfully" << endl;
    string jsonDataStr = "{\"name\":\""+ string(name) + "\", \"password\":\"" + string(password) + "\" , \"device\" :\"exe\"}";
    const char* jsonData = jsonDataStr.c_str();
    
    const string readBuffer = DataControllerC::APICall(jsonData,"login");
    const vector<string> vectorBuffer = DataControllerC::split(readBuffer, ',');
    const vector<string> resultVector = DataControllerC::split(vectorBuffer[0], ':');
    const vector<string> checkVector = DataControllerC::split(vectorBuffer[1], ':');
    if(checkVector[1] == "true"){
      const vector<string> tokenVector = DataControllerC::split(vectorBuffer[2], ':');
      HomeC::Home(name, tokenVector[1].c_str());
    }
  }else{
    cout << createResultBuffer[1] << endl;
    handleMenu(false);
  }
}

static const char* handleDob(const char* dob){
  if(strcmp(dob, "s") == 0){
    return "";
  }
  return dob;
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

void handleMenu(bool firstTime){
  const char* choice = "1";
  do{
    if(!firstTime){
      choice = DataControllerC::get_str_input("Try again (1) or 'q' to return to main menu: ");
    }
    if(strcmp(choice, "1") == 0){
      const char* name = DataControllerC::get_str_input("Enter Username: ");
      const char* password = DataControllerC::get_password_input("Enter Password: ");
      const char* email = DataControllerC::get_str_input("Enter Email: ");
      const char* dob = DataControllerC::get_str_input("Enter Dob (Format: YYYY-MM-DD, e.g: 1970-01-01) ('s' to skip): ");
      dob = handleDob(dob);
      const char* gender = DataControllerC::get_int_input("Enter Gender (1. Prefer not to say, 2. Male, 3. Female, 4. Others):", 1 , 4);
      gender = handleGender(gender);

      handleCreate(name, password, email, dob, gender);

    }else if(strcmp(choice, "q") == 0){
      MainC::mainMenu();
    }
  }while(strcmp(choice, "q") != 0);
}

void CreateC::Create(){
  handleMenu(true);
}