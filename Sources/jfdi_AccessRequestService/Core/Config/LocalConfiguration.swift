//
//  LocalConfiguration.swift
//  
//
//  Created by Patrick-Benjamin Bök on 18.08.23.
//
import Foundation


final class LocalConfiguration{
    
    //Enumeration of user default keys for accessing it everywhere in the application
    private enum userDefaultKeys: String{
        case EXAMPLE_A
        case EXAMPLE_B
        case OPEN_AI_API_KEY_A
        case VERSION
        case RANBEFORE
        case ACTIVELOGGER
    }
    
    //Local flags for updating the configuration and resetting the server configuration
    private var updateConfiguration = false
    private var resetDevice = false
    
    //Initalize configuration and read plist with configuration of userDefaultKeys; update possible via toogle
    init(){
        let configurationURL = Bundle.main.url(forResource: "LocalConfiguration", withExtension: "plist", subdirectory: "")
        if let configurationPath = configurationURL?.path,
           let configurationData = FileManager.default.contents(atPath: configurationPath) {
            do {
                let configuration = try PropertyListSerialization.propertyList(from: configurationData, options:PropertyListSerialization.ReadOptions(), format:nil)
                guard let configurationInput = configuration as? Dictionary<String, AnyObject> else {
                    return
                }
                self.updateConfiguration = configurationInput["update_conf"] as? Bool ?? false
                self.resetDevice = configurationInput["reset_conf"] as? Bool ?? false
                if(updateConfiguration){
                    LocalConfiguration.EXAMPLE_A = configurationInput["exampleString"] as? String ?? ""
                    LocalConfiguration.EXAMPLE_B = configurationInput["exampleBoolean"] as? Bool ?? false
                    LocalConfiguration.OPEN_AI_API_KEY_A = configurationInput["openAI_API_KEY_A"] as? String ?? ""
                }
                
                if(resetDevice || !LocalConfiguration.RANBEFORE){
                    LocalConfiguration.RANBEFORE = true
                    LocalConfiguration.ACTIVELOGGER = false
                    resetDevice = false
                }
            } catch {return}
        }
    }
    
    //Access methods to read and wirte the settings of this final class
    static var VERSION: String? {
        get{
            return ("Version " + ((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!) + " (Build " + ((Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)!) + ")")
        }
    }
    
    static var EXAMPLE_A: String!{
        get{
            return UserDefaults.standard.string(forKey: userDefaultKeys.EXAMPLE_A.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = userDefaultKeys.EXAMPLE_A.rawValue
            
            if let value = newValue{
                defaults.set(value, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var EXAMPLE_B: Bool!{
        get{
            return UserDefaults.standard.bool(forKey: userDefaultKeys.EXAMPLE_B.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = userDefaultKeys.EXAMPLE_B.rawValue
            
            if let value = newValue{
                defaults.set(value, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var OPEN_AI_API_KEY_A: String!{
        get{
            return UserDefaults.standard.string(forKey: userDefaultKeys.OPEN_AI_API_KEY_A.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = userDefaultKeys.OPEN_AI_API_KEY_A.rawValue
            
            if let value = newValue{
                defaults.set(value, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var RANBEFORE: Bool!{
        get{
            return UserDefaults.standard.bool(forKey: userDefaultKeys.RANBEFORE.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = userDefaultKeys.RANBEFORE.rawValue
            
            if let value = newValue{
                defaults.set(value, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var ACTIVELOGGER: Bool!{
        get{
            return UserDefaults.standard.bool(forKey: userDefaultKeys.ACTIVELOGGER.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = userDefaultKeys.ACTIVELOGGER.rawValue
            
            if let value = newValue{
                defaults.set(value, forKey: key)
            }
            else{
                defaults.removeObject(forKey: key)
            }
        }
    }
}
