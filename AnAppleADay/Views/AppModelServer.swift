//
//  AppModel.swift
//  EscapeRoom
//
//  Created by Marzia Pirozzi on 18/03/25.
//

import SwiftUI
import RealityKit

/// `AppModelServer` is responsible for maintaining the state related to the server connection.
///
/// This class stores network-related information such as the server address and port,
/// along with the file name used for streaming. It also manages UI state for input windows.
@MainActor @Observable
class AppModelServer {
    
    /// The IP address of the server used for streaming.
    var address: String = "10.20.50.9"
    
    /// The port number used for communication with the server.
    var port: String = "8000"
    
    /// The file name of the video stream (typically an HLS playlist file).
    var fileName: String = "xrayVideo.m3u8"
    
    /// A flag indicating whether the input window is currently open.
    var isInputWindowOpen: Bool = false
    
    /// Retrieves the status of the connection. It is connected if the view is showing feed
    var isConnected: Bool = false
}
