//
//  BackendFetchedResult.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

public enum BackendFetchedResult<T, Error> {
    case success(_ value: T)
    case failure(_ error: Error)
    case pending
}
