//
//  SessionsManager.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 21.09.2021.
//

import Foundation

class SessionsManager{
    
    static func getSavedSessions() -> [Session] {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)
        } catch {
            print(error)
        }
        return []
    }
}
