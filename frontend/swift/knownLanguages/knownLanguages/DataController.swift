//
//  DataController.swift
//  knownLanguages
//
//  Created by Tan Junhe on 29/7/23.
//

import Foundation
import UIKit

class IPSetting{
    static let sharedInstance = IPSetting()
    var IPAddres = ""
    var Port = ""
    var configFileDir = "config/config"//change this to base unless config.plist is created
    
    func setUrl() -> String{
        let ipSetting = IPSetting.sharedInstance
        if(ipSetting.IPAddres.count == 0 && ipSetting.Port.count == 0){
            guard let configFileURL = Bundle.main.url(forResource: configFileDir, withExtension: "plist"),
                  let configData = try? Data(contentsOf: configFileURL),
                  let config = try? PropertyListSerialization.propertyList(from: configData, format: nil) as? [String: Any]
            else {
                fatalError("Failed to load config.plist")
            }
            ipSetting.IPAddres = config["ipaddress"] as? String ?? ""
            ipSetting.Port = config["port"] as? String ?? ""
            
        }
        return "http://\(ipSetting.IPAddres):\(ipSetting.Port)/"
    }
}

class EndSession{
    static let sharedInstance = EndSession()
    
    func logout(){
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(identifier: "loginVC")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginVC)
    }
}

class UserGender{
    static let shareInstance = UserGender()
    
    var gender = [ "Prefer not to say", "Male", "Female", "Others"]
}

class FormatDate{
    
    func formatDateSQL(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func dateFromISOString(dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString) ?? Date()
    }

    func dateForPV(date: String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.date(from: date) ?? Date()
    }
}
