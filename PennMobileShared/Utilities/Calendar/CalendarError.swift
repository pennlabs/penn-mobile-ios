//
//  CalendarError.swift
//  PennMobile
//
//  Created by Ximing Luo on 3/14/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

public enum CalendarError: Error {
    case accessDenied
    case saveFailed(Error)
}
