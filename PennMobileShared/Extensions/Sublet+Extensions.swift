//
//  Sublet+Extensions.swift
//  PennMobile
//
//  Created by Anthony Li on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import Foundation

public extension Sublet {
    static let mock = Self(
        subletID: 0,
        data: .init(
            amenities: ["Private bathroom"],
            title: "Lauder",
            address: "3650 Locust Walk",
            beds: 9,
            baths: 6.5,
            externalLink: "",
            price: 820,
            negotiable: false,
            expiresAt: .endOfSemester,
            startDate: Day(),
            endDate: Day(date: .endOfSemester)
        ),
        subletter: 123456,
        offers: [SubletOffer(
            id: 0,
            data: .init(email: "fake@email.com", phoneNumber: "+1234567890", message: "I am interested!"),
            createdDate: Date(),
            user: 0,
            sublet: 0
        ), SubletOffer(
            id: 1,
            data: .init(email: "hello@world.com", phoneNumber: "+1098765432"),
            createdDate: Date(),
            user: 1,
            sublet: 0)
        ],
        images: [SubletImage(id: 0, imageUrl: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bWFuc2lvbnxlbnwwfHwwfHx8MA%3D%3D")]
    )
    static let mocks = [
        mock,
        Self(
            subletID: 1,
            data: .init(
                amenities: ["Balcony"],
                title: "Rittenhouse Square Studio",
                address: "2101 Market Street",
                beds: 1,
                baths: 1,
                externalLink: "",
                price: 1200,
                negotiable: true,
                expiresAt: .endOfSemester,
                startDate: Day(),
                endDate: Day(date: .endOfSemester)
            ),
            subletter: 53213,
            images: [SubletImage(id: 1, imageUrl: "https://images.unsplash.com/photo-1560184897-ae75f418493e?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXBhcnRtZW50fGVufDB8fDB8fHw%3D")]
        ),
        Self(
            subletID: 2,
            data: .init(
                amenities: ["Gym Access", "Pool Access"],
                title: "Modern 2BR in Center City",
                address: "1429 Chestnut Street",
                beds: 2,
                baths: 2,
                externalLink: "",
                price: 2000,
                negotiable: true,
                expiresAt: .endOfSemester,
                startDate: Day(),
                endDate: Day(date: .endOfSemester)
            ),
            subletter: 96232,
            images: [SubletImage(id: 2, imageUrl: "https://images.unsplash.com/photo-1494526585095-c41746248156?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXBhcnRtZW50fGVufDB8fDB8fHw%3D")]
        ),
        Self(
            subletID: 3,
            data: .init(
                amenities: ["Rooftop Access"],
                title: "Cozy Loft Near University City",
                address: "4001 Walnut Street",
                beds: 3,
                baths: 1.5,
                externalLink: "",
                price: 1500,
                negotiable: false,
                expiresAt: .endOfSemester,
                startDate: Day(),
                endDate: Day(date: .endOfSemester)
            ),
            subletter: 11923,
            images: [SubletImage(id: 3, imageUrl: "https://images.unsplash.com/photo-1570129477492-45c003edd2be?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y296eXxlbnwwfHwwfHx8MA%3D%3D")]
        )
    ]
}
