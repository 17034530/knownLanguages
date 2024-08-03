#include "dataController.h"
#include <limits>
#include <termios.h>
#include <unistd.h>
#include <cstring>
#include <fstream>
#include <sstream>
#include <cstdlib> // For setenv
#include <iostream>


using namespace std;

string DataControllerC::backendLink = "";


const char *DataControllerC::get_str_input(const string &str){
  string input;
  cout << str;
  getline(cin, input);
  char* cstr = new char[input.length() + 1];
  strcpy(cstr, input.c_str());
  return cstr;
}

const char *DataControllerC::get_password_input(const char *const str){
  struct termios oldt, newt;
  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~ECHO;
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);

  cout << str;
  string password;
  getline(cin, password);
  cout << endl;

  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);

  char* pw = new char[password.length() + 1];
  strcpy(pw, password.c_str());

  return pw;
}

const char *DataControllerC::get_int_input(const char *const str, int min, int max){
  int input;
  bool validInput = false;

  while (!validInput) {
    cout << str;
    string temp;
    getline(cin, temp);

    try {
      input = stoi(temp);

      if (input < min || input > max) {
        throw out_of_range("Input out of range");
      }

      validInput = true;
    } catch (const invalid_argument& e) {
      cout << "Invalid input. Please enter a valid number." << endl;
    } catch (const out_of_range& e) {
      cout << "Invalid input. Please enter a number between " << min << " and " << max << "." << endl;
    }
  }

  string result = to_string(input);
  char* resultCStr = new char[result.length() + 1];
  strcpy(resultCStr, result.c_str());

  return resultCStr;
}


// Callback function to capture the response from the server
const size_t DataControllerC::writeCallback(void* contents, size_t size, size_t nmemb, void* userp) {
  ((string*)userp)->append((char*)contents, size * nmemb);
  return size * nmemb;
}

const vector<string> DataControllerC::split(const string& str, char delimiter) {
  vector<string> tokens;
  string token;
  stringstream ss(str);

  while (getline(ss, token, delimiter)) {
    tokens.push_back(token);
  }
  return tokens;
}

void removeSubstring(string& str, const string& substring) {
    size_t pos;
    while ((pos = str.find(substring)) != string::npos) {
        str.erase(pos, substring.length());
    }
}

unordered_map<std::string, std::string> loadEnv(const std::string& filePath) {
    unordered_map<std::string, std::string> envMap;
    ifstream file(filePath);
    string line;

    if (!file.is_open()) {
        cerr << "Error: Could not open .env file." << std::endl;
        return envMap;
    }

    while (getline(file, line)) {
        stringstream is_line(line);
        string key;
        if (getline(is_line, key, '=')) {
            string value;
            if (getline(is_line, value)) {
                envMap[key] = value;
                // Optionally, you can also set these as environment variables
                // setenv(key.c_str(), value.c_str(), 1); // 1 means overwrite existing variables
            }
        }
    }

    file.close();
    return envMap;
}

const string DataControllerC::APICall(const char *data, const char *endPoint){
  CURL *curl;
  CURLcode res;

  curl_global_init(CURL_GLOBAL_DEFAULT);
  curl = curl_easy_init();
  if(curl) {
    // Response data from the server
    string readBuffer;
    if(DataControllerC::backendLink == ""){
      unordered_map<std::string, std::string> env = loadEnv("src/config/config.env");
      string ipa = "";
      string port = "";
      if (!env.empty()) {
        ipa = env["IPADDRESS"];
        port = env["PORT"];
      } else {
        cerr << "Error: Environment variables could not be loaded." << endl;
      }
      DataControllerC::backendLink = "http://"+string(ipa)+":"+string(port)+"/";
    }
    string link = backendLink+string(endPoint);
    // Set URL
    curl_easy_setopt(curl, CURLOPT_URL, link.c_str());
    // Set POST data
    if(strcmp(endPoint,"logout") == 0){
      curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");
    }else if(strcmp(endPoint,"updateProfile") == 0){
      curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "PATCH");
    }else{
      curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
    }

    
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_DEFAULT_PROTOCOL, "https");
          
    // Set headers
    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, "Content-Type: application/json");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);

    // Set callback function to capture the response
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, DataControllerC::writeCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

    res = curl_easy_perform(curl);
    // Check for errors
    if(res != CURLE_OK){
      cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << endl;
      cout << "Try again later" << endl;
      exit(0);
    }else{
      char toRemoveOpen1 = '{'; 
      char toRemoveClose1 = '}';
      char toRemove = '"';
      char toRemoveClose2 = ']';
      readBuffer.erase(remove(readBuffer.begin(), readBuffer.end(), toRemoveOpen1), readBuffer.end());
      readBuffer.erase(remove(readBuffer.begin(), readBuffer.end(), toRemoveClose1), readBuffer.end());
      readBuffer.erase(remove(readBuffer.begin(), readBuffer.end(), toRemove), readBuffer.end());
      removeSubstring(readBuffer, "result:[");
      readBuffer.erase(remove(readBuffer.begin(), readBuffer.end(), toRemoveClose2), readBuffer.end());
    }
    curl_easy_cleanup(curl);
    curl_slist_free_all(headers);
    curl_global_cleanup();
    return readBuffer;
  }else{
    cerr << "Sever down. Try again later" << endl;
    return "Fail";
  }
}

string DataControllerC::formatDateSQL(const char *dob){
  const vector<string> dateVector = DataControllerC::split(dob, '/');
  string formatDateStr = dateVector[2] + "-" + dateVector[0] + "-" + dateVector[1];
  return formatDateStr;
}

const char *DataControllerC::formatDateToSQL(const char *dob){
  const vector<string> dateVector = DataControllerC::split(dob, '/');
  string formatDateStr = dateVector[2] + "-" + dateVector[0] + "-" + dateVector[1];
  const char* formatDate = formatDateStr.c_str();
  return formatDate;
}
