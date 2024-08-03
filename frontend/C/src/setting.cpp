#include "setting.h"
#include "dataController.h"
#include "main.h"


static void handleSetting(){
  const char* ipa = DataControllerC::get_str_input("Enter New IP Address: ");
  const char* port = DataControllerC::get_str_input("Enter New Port: ");
  DataControllerC::backendLink = "http://"+string(ipa)+":"+string(port)+"/";
  cout << "Address have change to " << DataControllerC::backendLink << endl;
  MainC::mainMenu();
}

void SettingC::Setting(){
  handleSetting();
}