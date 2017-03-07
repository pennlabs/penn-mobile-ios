//
//  NetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 2/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let weatherURL = "https://api.pennlabs.org/weather"
    
    //callback gives a dict with "temp" and "description"
    static func getWeatherData(callback: @escaping (_ info: [String: AnyObject]) -> ()) {
        getRequest(url: weatherURL, callback: { (data) in
            
            var infoDict = [String: AnyObject]()
            
            if let dict = data as? [String: AnyObject] {
                if let array: AnyObject = dict["weather_data"] {
                    
                    if let dictionary = array as? [String: AnyObject] {
                        if let mainDict = dictionary["main"] as? [String: AnyObject] {
                            if let temp = mainDict["temp"] as? Int {
                                infoDict["temp"] = temp as AnyObject
                            }
                        }
                        
                        if let weatherArray = dictionary["weather"] as? [AnyObject] {
                            for dictionary in weatherArray {
                                if let dictionary = dictionary as? [String: AnyObject], let description = dictionary["description"] {
        
                                    infoDict["description"] = description
                                }
                            }
                        }
                    }
                }
                
                callback(infoDict)
            } else {
                print("Results key not found in dictionary")
            }
        
        })
    }
    
    private static func getRequest(url: String, callback: @escaping (_ json: NSDictionary?) -> ()) {
        let url = URL(string: url)
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "GET"
        do {
            //let params = ["item":item, "location":location,"username":username]
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            //request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                //
                
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                    }
                }
                
                //let resultNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                if let data = data, let _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        
                        callback(json)
                        
                    }
                } else {
                    callback(nil)
                }
                
            })
            task.resume()
        }
    }
    
}
