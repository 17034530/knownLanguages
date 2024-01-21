//
//  LoginVC.swift
//  knownLanguages
//
//  Created by Tan Junhe on 20/1/24.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var ipSetting: UIBarButtonItem!
    var name = ""
    var password = ""
    var device = ""
    
    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        url = IPSetting.sharedInstance.setUrl()
        linkIPSettingVC()
    }
    
    //to load everytime the page got call from IPsettingVC/sign up return
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        url = IPSetting.sharedInstance.setUrl()
        linkIPSettingVC()
    }
    
    func linkIPSettingVC(){
        #if DEBUG
            ipSetting.isEnabled = false
            ipSetting.tintColor = UIColor.clear
        #else
            ipSetting.isEnabled = true
        #endif
    }
    
    func loadDefaults(){
        nameTF.text = ""
        passwordTF.text = ""
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        name = nameTF.text!
        password = passwordTF.text!
        device = UIDevice().name
        let params = ["name":name,
                      "password":password,
                      "device": device]
        self.apiCall(endPoint: "login", params: params, resMethod: "POST")
    }
    
    func alertShowUp(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        {(action: UIAlertAction!) in
            self.loadDefaults()
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
                return
            }else{
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                     if(endPoint == "login"){
                        if(json["check"]! as! Bool){
                            UserDefaults.standard.set(json["token"]! as! String,forKey: "token")
                            UserDefaults.standard.set(self.name,forKey: "name")
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBar")
                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.alertShowUp(title: "Error", message: json["result"] as! String)
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


