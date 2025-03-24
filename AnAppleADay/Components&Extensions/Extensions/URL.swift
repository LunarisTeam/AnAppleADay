//
//  URL.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 12/11/24.
//

import Foundation

extension URL {
    
    func whileAccessingSecurityScopedResource<T>(handler: () throws -> T) rethrows -> T {
        
        let accessingScopedResource = self.startAccessingSecurityScopedResource()
        
        defer {
            if accessingScopedResource { self.stopAccessingSecurityScopedResource() }
        }
        
        return try handler()
    }
}
