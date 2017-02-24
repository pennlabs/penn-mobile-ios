//
//  WeatherParser.swift
//  PennMobile
//
//  Created by Victor Chien on 2/4/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import Foundation

//parse weather shit in here

class WeatherParser {

    static func getData() -> String {
        var name2 = ""
        let requestURL: NSURL = NSURL(string: "https://api.pennlabs.org/weather")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! NSDictionary
                    
                    
                    if let stations = json["weather_data"] as? [[String: AnyObject]] {
                        for station in stations {
                            if let name = station["temp"] as? String {
                                name2 = name
                            }
                            
                            //                            if let latitude = station["latitude"] as? String {
                            //                            }
                            //
                            //                            if let longitude = station["longitude"] as? String {
                            //                            }
                        }
                    }
                    
                }
                catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
        return name2


    }
    
    
    
}
