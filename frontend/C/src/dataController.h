#ifndef DATACONTROLLER_H
#define DATACONTROLLER_H

#include <string>
#include <iostream>
#include <sstream>
#include <vector>
#include <curl/curl.h>


using namespace std;

class DataControllerC{
public:
  static string backendLink;

  static const char* get_str_input(const string& str);
  
  static const char* get_password_input(const char* const str);

  static const char* get_int_input(const char* const str, int min, int max);

  static const size_t writeCallback(void* contents, size_t size, size_t nmemb, void* userp);

  static const vector<string> split(const string& str, char delimiter);

  static const string APICall(const char* data, const char* endPoint);

  static string formatDateSQL(const char* dob);

  static const char* formatDateToSQL(const char* dob);
};

#endif