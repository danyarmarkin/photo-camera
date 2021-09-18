//
//  Session.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 17.09.2021.
//

import Foundation


class Session {
    var objectName = ""
    var sessionName = ""
    var deviceIndex = 0
    var deviceAmount = 0
    var date = ""
    var time = ""


    func getFullName() -> String {
        if time == "" {
            return "\(objectName)_\(sessionName)_\(deviceIndex)\(deviceAmount)_\(date)"
        }
        if date == "" {
            return "\(objectName)_\(sessionName)_\(deviceIndex)\(deviceAmount)"
        }
        return "\(objectName)_\(sessionName)_\(deviceIndex)\(deviceAmount)_\(date)_\(time)"
    }
    
    func getShortName() -> String {
        "_\(sessionName)_\(deviceIndex)\(deviceAmount)"
    }
    
    func getFileName(ind: Int) -> String {
        let c = 4 - "\(ind)".count
        return "\(sessionName)_\(String(repeating: "0", count: c))\(ind)_\(deviceIndex)\(deviceAmount).jpeg"
    }
    
}
