//
//  CreateVC.swift
//  knownLanguages
//
//  Created by Tan Junhe on 20/1/24.
//

import UIKit

class CreateVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var genderPV: UIPickerView!
    let datePicker = UIDatePicker()
    
    var FD = FormatDate()
    var genderList = UserGender.sharedInstance.gender
    var name = ""
    var dob = ""
    var gender = ""
    
    var url = IPSetting.sharedInstance.setUrl()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.maximumDate = Date()
        dobTF.inputView = datePicker
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            } else {
                
            }
        }

        genderPV.delegate = self
        genderPV.dataSource = self
        gender = genderList[0]
        
    }
    
    
    @IBAction func createBtn(_ sender: Any) {
        name = nameTF.text!
        gender = gender == genderList[0] ? "" : gender
        dob = dobTF.text!.isEmpty ? "" : FD.formatDateSQL(date: datePicker.date)
        let params = ["name":nameTF.text!,
                      "password":passwordTF.text!,
                      "email":emailTF.text!,
                      "dob":dob,
                      "gender": gender]
        self.apiCall(endPoint: "createUser", params: params, resMethod: "POST")
    }
    
    //datePicker
    @objc func dateChange(datePicker: UIDatePicker){
        dobTF.text = FD.formatDate(date: datePicker.date)
        dob = FD.formatDateSQL(date: datePicker.date)
    }
    
    //pickerView gender
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        gender = genderList[row]
    }
    
    func loadDefaults(){
        nameTF.text = ""
        passwordTF.text = ""
        emailTF.text = ""
        dobTF.text = ""
        name = ""
        dob = ""
        gender = genderList[0]
        genderPV.selectRow(0, inComponent: 0, animated: true)
    }
    
    //for frontend to check before calling of api
    /*
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let pattern = "^(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[a-z\\d@$!%*?&]{8,10}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: password.utf16.count)
        return regex.firstMatch(in: password, options: [], range: range) != nil
    }
    */
    
    func alertShowUp(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        {(action: UIAlertAction!) in
            if(title == "Successfully"){
                //auto login if create successfully
                let params = ["name":self.nameTF.text!,
                              "password":self.passwordTF.text!,
                              "device":UIDevice().name]
                self.apiCall(endPoint: "login", params: params, resMethod: "POST")
            }else{
                if(message.lowercased().contains("name")){
                    self.name = ""
                    self.nameTF.text = ""
                }else if(message.lowercased().contains("password")){
                    self.passwordTF.text = ""
                }else if(message.lowercased().contains("email")){
                    self.emailTF.text = ""
                }else{
                    self.loadDefaults()
                }
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func apiCall(endPoint: String, params: Any, resMethod: String ){
        var request = URLRequest(url: URL(string: "\(url)\(endPoint)")!)
        request.httpMethod = resMethod
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertShowUp(title: "Error", message: error.localizedDescription)
                }
            }else{
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    if(endPoint == "createUser"){
                        DispatchQueue.main.async {
                            
                            self.alertShowUp(title: (json["check"]!) as! Bool ? "Successfully" : "Error", message:json["result"]! as! String)
                            
                        }
                    }else if(endPoint == "login"){
                        if(json["check"]! as! Bool){
                            UserDefaults.standard.set(json["token"]! as! String,forKey: "token")
                            UserDefaults.standard.set(self.name,forKey: "name")
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBar")
                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                            }
                        }
                    }
                }catch{
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

