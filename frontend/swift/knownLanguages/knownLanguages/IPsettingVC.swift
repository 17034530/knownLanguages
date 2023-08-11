//
//  IPsettingVC.swift
//  knownLanguages
//
//  Created by Tan Junhe on 29/7/23.
//

import UIKit

class IPsettingVC: UIViewController {
    
    @IBOutlet weak var IPAddressTF: UITextField!
    @IBOutlet weak var PortTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func alertShowUp(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        {(action: UIAlertAction!) in
            if(title == "Updated"){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(identifier: "loginVC")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginVC)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }

    @IBAction func AddIPBtn(_ sender: Any) {
        if(IPAddressTF.text! != "" && PortTF.text! != ""){
            let IPSetting = IPSetting.sharedInstance
            IPSetting.IPAddres = IPAddressTF.text!
            IPSetting.Port = PortTF.text!
            alertShowUp(title: "Updated", message: "Your new IP address is \(IPSetting.IPAddres) and port is \(IPSetting.Port)")
        }else{
            alertShowUp(title: "Error", message: "Fail to updated")
        }
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
