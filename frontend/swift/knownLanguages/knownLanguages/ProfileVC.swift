//
//  ProfileVC.swift
//  knownLanguages
//
//  Created by Tan Junhe on 29/7/23.
//

import UIKit

class ProfileVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var currentPWTF: UITextField!
    @IBOutlet weak var newPWFT: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var genderPV: UIPickerView!
    let datePicker = UIDatePicker()

    var FD = FormatDate();
    
    var url = IPSetting.sharedInstance.setUrl()
    var genderList = UserGender.shareInstance.gender
    
    var name = UserDefaults.standard.string(forKey: "name")
    var token = UserDefaults.standard.string(forKey: "token")
    var dob = ""
    var gender = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startload()
    }
    
    func startload(){
        //get user info
        let params = ["name":UserDefaults.standard.string(forKey: "name"),
                      "token":UserDefaults.standard.string(forKey: "token")]
        self.apiCall(endPoint: "profile", params: params, resMethod: "POST")
        
        nameTF.text = name
        
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
    }
    
    @IBAction func updateBtn(_ sender: Any) {
        gender = gender == genderList[0] ? "" : gender
        dob = dobTF.text!.isEmpty ? "" : FD.formatDateSQL(date: datePicker.date)
        let params = ["name":name,
                      "password":currentPWTF.text!,
                      "newPassword":newPWFT.text!,
                      "email":emailTF.text!,
                      "dob":dob,
                      "gender": gender,
                      "token":token]
        self.apiCall(endPoint: "updateProfile", params: params, resMethod: "PATCH")
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        logout()
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
    
    func logout(){
        let params = ["name":name,
                      "token":token]
        self.apiCall(endPoint: "logout", params: params , resMethod: "DELETE")
    }
    
    func alertShowUp(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        {(action: UIAlertAction!) in
            
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
                    if(endPoint == "logout"){
                        DispatchQueue.main.async {
                            EndSession.sharedInstance.logout()
                        }
                    }else if(endPoint == "profile"){
                        if((json["check"])! as! Bool){
                            let result = json["result"] as! Array<Dictionary<String, AnyObject>>
                            let result0 = result[0]
                            DispatchQueue.main.async {
                                self.emailTF.text = result0["email"]! as? String
                                
                                let resultdob = result0["DOB"]! as Any
                                self.dob = resultdob is String ? self.FD.formatDate(date: self.FD.dateFromISOString(dateString: resultdob as! String)) : ""
                                self.dobTF.text = self.dob
                                
                                self.datePicker.date = !self.dob.isEmpty ?
                                self.FD.dateForPV(date: self.dob) : Date()
                                
                                let resultgender = result0["gender"]! as Any
                                self.gender = resultgender is String ? resultgender as! String : self.genderList[0]
                                self.genderPV.selectRow(self.genderList.firstIndex(of: self.gender) ?? 0, inComponent: 0, animated: true)
                            }
                        }
                    }else if(endPoint == "updateProfile"){
                        DispatchQueue.main.async {
                            self.alertShowUp(title: json["check"]! as! Bool ? "Successfully" : "Error" , message: json["result"] as! String)
                            self.currentPWTF.text = ""
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
