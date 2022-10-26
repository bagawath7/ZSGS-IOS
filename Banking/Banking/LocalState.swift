//
//  LocalState.swift
//  Bankey
//
//  Created by jrasmusson on 2021-10-08.
//

import Foundation

public class LocalState {
    
    private enum Keys: String {
        case hasOnboarded
        case username
        case password
    }
    
    public static var hasOnboarded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.hasOnboarded.rawValue)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.hasOnboarded.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    public static var username: String{
        get{
            return UserDefaults.standard.string(forKey: Keys.username.rawValue) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.username.rawValue)
        }
        
    }
    public static var password: String{
        get{
            return UserDefaults.standard.string(forKey: Keys.password.rawValue) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.password.rawValue)
        }
        
    }
}
