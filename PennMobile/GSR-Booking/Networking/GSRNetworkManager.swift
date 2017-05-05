//
//  NetworkManager.swift
//  GSR
//
//  Created by Yagil Burowski on 15/09/2016.
//  Copyright © 2016 Yagil Burowski. All rights reserved.
//

import Foundation


class GSRNetworkManager: NSObject {
    static let availUrl = "http://libcal.library.upenn.edu/process_roombookings.php"
    
    public typealias AuthenticateCallback = (_ isValid: Bool) -> Void
    fileprivate var authenticateCallback: AuthenticateCallback?
    
    var email : String?
    var password: String?
    var gid : Int?
    var ids : [Int]?
    var session : URLSession?
    
    var doNotBook = false
    
    static let shared = GSRNetworkManager()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init(email: String, password: String, gid: Int, ids: [Int]) {
        self.init()
        self.email = email
        self.password = password
        self.gid = gid
        self.ids = ids
    }
    
    //static private func isGoodAuthentication(_ dataString: String
    
    static func getHours(_ date: String, gid: Int, callback: @escaping (AnyObject) -> ()) {
        let headers = [
            "Referer": "http://libcal.library.upenn.edu/booking/vpdlc"
        ]
        
        let url = availUrl + "?m=calscroll&date=\(date)&gid=\(gid)"
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                callback(error! as AnyObject)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                callback(response!)
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            
            callback(responseString! as AnyObject)
        }
        
        task.resume()
    }
    
    // MARK: - crazy experiemnt
    
    private func getValidRoom(callback: @escaping (_ gid: Int?, _ ids: [Int]?, _ error: Error?) -> ()) {
        guard let date = DateHandler.getDates().last?.compact, let gid = LocationsHandler.getLocations().first?.code else { return }
        
        GSRNetworkManager.getHours(date, gid: gid) {
            (res: AnyObject) in
            
            if (res is NSError) {
                callback(nil, nil, res as? Error)
            } else {
                let minDate = Parser.getDateFromTime(time: "12:00am")
                let maxDate = Parser.getDateFromTime(time: "11:59pm")
                let roomData = Parser.getAvailableTimeSlots(res as! String, startDate: minDate, endDate: maxDate)
                let dictIndex: Int = Int(arc4random_uniform(UInt32(roomData.count)))
                let randomRoom = Array(roomData.values)[dictIndex]
                let hourIndex: Int = Int(arc4random_uniform(UInt32(randomRoom.count)))
                callback(gid, [randomRoom[hourIndex].id], nil)
            }
        }
    }
    
    func authenticateEmailPassword(email: String, password: String, _ callback: AuthenticateCallback?) {
        let defaults = UserDefaults.standard
        
        let storedEmail = defaults.string(forKey: "email")
        let storedPassword = defaults.string(forKey: "password")
        
        if email == storedEmail && password == storedPassword {
            callback?(true)
            return
        }
        
        getValidRoom() { (gid, ids, error) in
            self.email = email
            self.password = password
            self.gid = gid
            self.ids = ids
            self.doNotBook = true
            
            self.authenticateCallback = callback
            self.bookSelection()
        }
    }
    
    func bookSelection() {
        let request = NSMutableURLRequest(url: URL(string: "http://libcal.library.upenn.edu/booking/vpdlc")!)
        self.sendNotification("msg", msg: "Starting up...")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.initiateProcess()
        }
        
        task.resume()
    }
    
    func initiateProcess() {
        let request = NSMutableURLRequest(url: URL(string: "http://libcal.library.upenn.edu/libauth_s_r.php")!)
        
        request.httpMethod = "POST"
        
        let bodyData = "tc=done&p1=\(Parser.idsArrayToString(ids!))&p2=\(gid!)&p3=8&p4=0&iid=335"
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            
            self.sendNotification("msg", msg: "Some back and forth...")
            
            if let nextUrl = response?.url! {
                self.get1(nextUrl)
            }
        }
        
        task.resume()
    }
    
    func get1(_ url : URL) {
        let request = NSMutableURLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.sendNotification("msg", msg: "Some back and forth...")
            
            self.get2(url)
        }
        
        task.resume()
    }
    
    func get2(_ url : URL) {
        let appendStr = "&idpentityid=https%3A%2F%2Fidp.pennkey.upenn.edu%2Fidp%2Fshibboleth"
        let getUrl = URL(string: url.absoluteString + appendStr)
        let request = NSMutableURLRequest(url: getUrl!)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.sendNotification("msg", msg: "Negotiating with artificial intelligence...")
            if let nextUrl = response?.url! {
                self.get3(nextUrl, referer: (getUrl?.absoluteString)!)
            }
        }
        
        task.resume()
        
    }
    
    
    func get3(_ url : URL, referer : String) {
        let request = NSMutableURLRequest(url: url)
        
        
        request.setValue(referer, forHTTPHeaderField: "Referer")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            self.sendNotification("msg", msg: "Making more progress...")
            self.authenticate()
        }
        
        task.resume()
        
    }
    
    func authenticate() {
        let pennKey = email!.components(separatedBy: "@")[0]
        let request = NSMutableURLRequest(url: URL(string: "https://weblogin.pennkey.upenn.edu/login")!)
        request.httpMethod = "POST"
        let bodyData = "login=\(pennKey)&password=\(password!)&required=UPENN.EDU&ref=https://idp.pennkey.upenn.edu/idp/Authn/RemoteUser&service=cosign-pennkey-idp-0"
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        request.setValue("https://weblogin.pennkey.upenn.edu/login?factors=UPENN.EDU&cosign-pennkey-idp-0&https://idp.pennkey.upenn.edu/idp/Authn/RemoteUser", forHTTPHeaderField: "Referer")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            self.sendNotification("msg", msg: "Providing the secret password...")
            self.postAuthenticate(dataString! as String)
        }
        
        task.resume()
    }
    
    func postAuthenticate(_ dataString : String) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://libauth.com/saml/module.php/saml/sp/saml2-acs.php/springy-sp")!)
        request.httpMethod = "POST"
        
        let SAMLResponse = Parser.dataStringToSAMLResponse(dataString)
        let bodyData = "RelayState=https%3A%2F%2Flibauth.com%2Fsaml%2Fmodule.php%2Fcore%2Fauthenticate.php%3Fas%3Dspringy-sp&SAMLResponse=\(SAMLResponse)"
        
        if doNotBook {
            DispatchQueue.main.async {
                self.authenticateCallback?(SAMLResponse != "")
            }
            return
        }
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        request.setValue("https://idp.pennkey.upenn.edu/idp/profile/SAML2/Redirect/SSO", forHTTPHeaderField: "Referer")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            guard error == nil && data != nil else {   // check for fundamental networking error
                self.handleError()
                return
            }
            if let url = response?.url! {
                self.postBooking(url.absoluteString)
                self.sendNotification("msg", msg: "Finalizing everything...")
            }
        }
        
        task.resume()
        
    }
    
    func postBooking(_ referrer : String) {
        let request = NSMutableURLRequest(url: URL(string: "http://libcal.library.upenn.edu/process_roombookings.php?m=booking_full")!)
        request.httpMethod = "POST"
        
        let bodyData = "gid=\(gid!)&iid=335&email=\(email!)&nick=strategy&q1=2-3&qcount=1&fid=919"
        request.setValue(referrer, forHTTPHeaderField: "Referer")
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error == nil {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if dataString == "ProcPage::invalid request" {
                    self.sendNotification("msg", msg: "Request Failed")
                    let errorMessage = "<body style='font-family:Helvetica'><h3>Possible reasons:</h3>" +
                        "<ul>" +
                        "<li>You may have entered the wrong email or password. In this case, login and try again.</li>" +
                        "<li>You might have exceeded your daily booking limit.</li>" +
                        "<li>Exit the app, wait a few minutes and try again.</li>" +
                        "<li>For anything else contact <a href='mailto:contactpennmobile@gmail.com'>contactpennmobile@gmail.com</a></li>" +
                    "</ul></body>"
                    self.sendNotification("status", msg: errorMessage)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] {
                        
                        let msg = json["msg"] as! String
                        switch json["status"] as! Int {
                        case 0:
                            self.sendNotification("msg", msg: "Encountered Error:")
                            self.sendNotification("status", msg: msg)
                            break
                        case 2:
                            self.sendNotification("msg", msg: "Result:")
                            self.sendNotification("status", msg: "<body style='font-family:Helvetica'>\(msg)</body>")
                        default:
                            break
                        }
                    }
                } catch {
                    self.sendNotification("msg", msg: "Request Failed")
                    let errorMessage = "<body style='font-family:Helvetica'><h3>Possible reasons:</h3>" +
                        "<ul>" +
                        "<li>You may have entered the wrong email or password. In this case, login and try again.</li>" +
                        "<li>You might have exceeded your daily booking limit.</li>" +
                        "<li>Exit the app, wait a few minutes and try again.</li>" +
                        "<li>For anything else contact <a href='mailto:contactpennmobile@gmail.com'>contactpennmobile@gmail.com</a></li>" +
                    "</ul></body>"
                    self.sendNotification("status", msg: errorMessage)
                }
            } else {
                self.handleError()
            }
        }
        
        task.resume()
    }
    
    func sendNotification(_ type: String, msg : String) {
        switch type {
        case "msg":
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ProgressMessageNotification"), object: msg)
            break
        case "status":
            NotificationCenter.default.post(name: Notification.Name(rawValue: "StatusMessageNotification"), object: msg)
        default:
            break
        }
        
    }
    fileprivate func handleError() {
        self.sendNotification("msg", msg: "Request Failed")
        self.sendNotification("status", msg: "<p style='font-family:Helvetica'>Email  contactpennmobile@gmail.com to get help</p>")
    }
}


