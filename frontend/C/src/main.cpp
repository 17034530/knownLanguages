#include "main.h"
#include <iostream>
#include "dataController.h"
#include "setting.h"
#include "login.h"
#include "create.h"

using namespace std;

static void displayMenu(){
  cout << "Welcome to knownLanguages" << endl;
  cout << "1. Login" << endl;
  cout << "2. Create" << endl;
  cout << "3. Setting" << endl;
  cout << "m. menu" << endl;
}

void MainC::mainMenu(){
  displayMenu();
  const char* choice;
  do{
    choice = DataControllerC::get_str_input("Enter An Option (q: quit): ");
    if(strcmp(choice, "1") == 0){
      LoginC::Login();
    }else if(strcmp(choice, "2") == 0){
      CreateC::Create();
    }else if(strcmp(choice,"3") == 0){
      SettingC::Setting();
    }else if(strcmp(choice,"m") == 0){
      displayMenu();
    }else if(strcmp(choice, "q") == 0){
      exit(0);
    }
  }while(strcmp(choice, "q") != 0);

}

int main(){
  MainC::mainMenu();
}