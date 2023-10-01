//
//  ProfilePageNetworkManager.swift
//  PennMobile
//
//  Created by Andrew Antenberg on 10/10/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON
import PennMobileShared

class ProfilePageNetworkManager: NSObject, Requestable {

    static let instance = ProfilePageNetworkManager()

    let schoolsURL = "https://platform.pennlabs.org/accounts/schools/"
    let majorsURL = "https://platform.pennlabs.org/accounts/majors/"

    func getSchools (completion: @escaping (Result<[School], NetworkingError>) -> Void) {
        let url = URL(string: self.schoolsURL)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, _) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                do {
                    let schools = try decoder.decode([School].self, from: data)
                    completion(.success(schools))
                } catch {
                    completion(.failure(.parsingError))
                }
            }
        }
        task.resume()
    }

    func getMajors (completion: @escaping (Result<[Major], NetworkingError>) -> Void) {
        let url = URL(string: self.majorsURL)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, _) in
            if let httpResponse = response as? HTTPURLResponse, let data = data, httpResponse.statusCode == 200 {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                do {
                    let majors = try decoder.decode([Major].self, from: data)
                    completion(.success(majors))
                } catch {
                    completion(.failure(.parsingError))
                }
            }
        }
        task.resume()
    }
}
