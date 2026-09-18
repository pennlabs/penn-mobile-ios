//
//  MultipartBuilder.swift
//  PennMobile
//
//  Created by Anthony Li on 1/28/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

@resultBuilder
public struct MultipartBuilder {
    public static func buildExpression(_ expression: MultipartContent) -> [MultipartContent] {
        [expression]
    }
    
    public static func buildBlock(_ components: [MultipartContent]...) -> [MultipartContent] {
        Array(components.joined())
    }
    
    public static func buildOptional(_ component: [MultipartContent]?) -> [MultipartContent] {
        component ?? []
    }
    
    public static func buildEither(first component: [MultipartContent]) -> [MultipartContent] {
        component
    }
    
    public static func buildEither(second component: [MultipartContent]) -> [MultipartContent] {
        component
    }
    
    public static func buildArray(_ components: [[MultipartContent]]) -> [MultipartContent] {
        Array(components.joined())
    }
    
    public static func buildLimitedAvailability(_ component: [MultipartContent]) -> [MultipartContent] {
        component
    }
}
