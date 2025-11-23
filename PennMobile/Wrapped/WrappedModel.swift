//
//  WrappedData.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 11/22/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation
import Lottie
import CoreText

public struct WrappedModel: Decodable {
    let semester: String
    // Designed to be optional for forwards compatability
    // (making pages an optional field was a design discussion for disabling wrapped between semesters)
    var pages: [WrappedUnit]
    let fonts: [String: URL]
    
    var fontProvider: WrappedFontProvider?
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.semester = try values.decode(String.self, forKey: .semester)
        self.pages = try values.decodeIfPresent([WrappedUnit].self, forKey: .pages) ?? []
        self.fonts = try values.decodeIfPresent([String: URL].self, forKey: .fonts) ?? [:]
    }
    
    public init(semester: String, pages: [WrappedUnit], fonts: [String: URL] = [:]) {
        self.pages = pages
        self.semester = semester
        self.fonts = fonts
    }
    
    enum CodingKeys: String, CodingKey {
        case pages, semester, fonts
    }
    
    mutating func loadModel() async {
        let newPages = await withTaskGroup(of: WrappedUnit.self, returning: [WrappedUnit].self) { group in
            for page in self.pages {
                var newPage = page
                group.addTask {
                    await newPage.loadAnimation()
                    return newPage
                }
            }
            
            var results: [WrappedUnit] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        // Fail if duplicate ID (note: this silently fails)
        // There should be exactly one of every ID
        guard newPages.compactMap({ el in
            newPages.count(where: { $0.id == el.id })
        }).filter({ $0 != 1 }).isEmpty else {
            print("Wrapped duplicate IDs detected. Check the model.")
            self.pages = []
            return
        }
        
        self.pages = newPages.filter({ $0.lottie != nil }).sorted(by: { $0.id < $1.id })
        
        let fontFiles: [String: Data] = await withTaskGroup(of: (String, Data?).self, returning: [String: Data].self) { group in
            for (name, downloadURL) in self.fonts {
                group.addTask {
                    let request = URLRequest(url: downloadURL)
                    guard let (localURL, response) = try? await URLSession.shared.download(for: request) else {
                        return (name, nil)
                    }
                    return (name, try? Data(contentsOf: localURL))
                }
            }
            
            var results: [String: Data] = [:]
            for await result in group {
                guard result.1 != nil else { continue }
                results[result.0] = result.1
            }
            return results
        }
        
        self.fontProvider = WrappedFontProvider(from: fontFiles)
    }
}

class WrappedFontProvider: AnimationFontProvider, Equatable {
    static func == (lhs: WrappedFontProvider, rhs: WrappedFontProvider) -> Bool {
        lhs === rhs
    }
    
    let fonts: [String: CGFont]
    init(from files: [String: Data]) {
        var fonts: [String: CGFont] = [:]
        for (name, data) in files {
            if let provider = CGDataProvider(data: data as CFData) {
                fonts[name] = CGFont(provider)
            }
        }
        self.fonts = fonts
    }
    
    func fontFor(family: String, size: CGFloat) -> CTFont? {
        guard let font = fonts[family] else { return nil }
        let ctFont = CTFontCreateWithGraphicsFont(font, size, nil, nil)
        return ctFont
    }
}
