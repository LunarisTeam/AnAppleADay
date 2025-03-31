//
//  AppModel.swift
//  EscapeRoom
//
//  Created by Marzia Pirozzi on 18/03/25.
//

import SwiftUI
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    var address: String = "10.20.50.9"
    var port: String = "8000"
    var fileName: String = "xrayVideo.m3u8"
    var hideBar: Bool = false
    var bonesEntity: Entity? = nil
    var arteriesEntity: Entity? = nil
    var scale: Bool = false
}
