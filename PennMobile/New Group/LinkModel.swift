//
//  LinkModel.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 4/22/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation


struct Link {
    var name: String
    var url: URL
    
    init(name: String, urlString: String ) {
        self.name = name
        self.url =  URL(string: urlString)!
    }
}

class LinkModel: NSObject {
    
    static var shared = LinkModel()
    
    let links: [Link] = {
        var links = [Link]()
        links.append(Link(name: "Penn In Touch", urlString: "https://pennintouch.apps.upenn.edu"))
        links.append(Link(name: "Penn Course Review", urlString: "https://penncoursereview.com/"))
        links.append(Link(name: "Penn Course Alert", urlString: "https://penncoursealert.com/"))
        links.append(Link(name: "Penn Transit", urlString: "https://www.pennrides.com/"))
        links.append(Link(name: "Campus Express", urlString: "https://prod.campusexpress.upenn.edu/"))
        return links
    }()

}
