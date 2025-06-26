//
//  InputAddress.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 28/03/25.
//

import Foundation
import SwiftUI
import RealityKitContent
import RealityKit

/// A SwiftUI view that allows the user to manually input an IP address and port number
/// to connect to a video stream source (e.g., a fluoroscope server).
///
/// The view consists of a four-field segmented IP input, a port number field, and a "Connect" button.
/// Once submitted, a `VideoEntity` is created via the `AppModel`, and the window dismisses.
struct InputAddressView: View {
    
    /// Environment object for controlling application state and video connection logic.
    @Environment(AppModel.self) private var appModel

    /// Used to open new SwiftUI windows programmatically (currently unused here).
    @Environment(\.openWindow) private var openWindow

    /// Used to dismiss the current input window after connection.
    @Environment(\.dismissWindow) private var dismissWindow

    /// First octet of the IP address.
    @State private var first: String = ""

    /// Second octet of the IP address.
    @State private var second: String = ""

    /// Third octet of the IP address.
    @State private var third: String = ""

    /// Fourth octet of the IP address.
    @State private var fourth: String = ""

    /// Port number to use when connecting to the stream.
    @State private var port: String = ""

    var body: some View {
        ZStack {
            Color.background.opacity(0.3)

            VStack {
                // MARK: Header
                Text("Input information to connect")
                    .font(.title)
                    .padding(.vertical, 10)

                // MARK: Input Form
                Form {
                    // IP Address Section
                    Section("IP address") {
                        HStack(spacing: 5) {
                            TextField(text: $first) {
                                Text("00").font(.title2)
                            }.keyboardType(.numberPad)

                            Text(".").padding(.horizontal)

                            TextField(text: $second) {
                                Text("00").font(.title2)
                            }.keyboardType(.numberPad)

                            Text(".").padding(.horizontal)

                            TextField(text: $third) {
                                Text("00").font(.title2)
                            }.keyboardType(.numberPad)

                            Text(".").padding(.horizontal)

                            TextField(text: $fourth) {
                                Text("00").font(.title2)
                            }.keyboardType(.numberPad)
                        }
                    }

                    // Port Number Section
                    Section("Port number") {
                        TextField(text: $port) {
                            Text("Port number").font(.title2)
                        }.keyboardType(.numberPad)
                    }
                }

                // MARK: Connect Button
                Button {
                    let address = [first, second, third, fourth].joined(separator: ".")
                    
                    Task {
                        await appModel.createVideoEntity(address: address, port: port)
                        dismissWindow(id: WindowIDs.inputAddressWindowID)
                    }
                } label: {
                    Text("Connect")
                        .font(.title2)
                }
            }
            .padding(20)
        }
        // Update app state flags on window appearance and disappearance
        .onAppear { appModel.isInputWindowOpen = true }
        .onDisappear { appModel.isInputWindowOpen = false }
        .glassBackgroundEffect()
    }
}
