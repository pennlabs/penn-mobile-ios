//
//  Utilities.swift
//  PennMobile
//
//  Created by Nathan Aronson on 10/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public enum ResultWithLoading<T> {
    case success(T)
    case failure(Error)
    case loading
}
