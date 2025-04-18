//
//  InputAddress.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 28/03/25.
//
import Foundation
import SwiftUI
import RealityKit

struct InputAddressView: View {
    
    @Environment(AppModelServer.self) private var appModelServer
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var first: String = ""
    @State private var second: String = ""
    @State private var third: String = ""
    @State private var fourth: String = ""
    @State private var port: String = ""
    
    var body: some View {
        
        ZStack {
            Color.background.opacity(0.3)
            
            VStack {
                
                Text("Input information to connect")
                    .font(.title)
                    .padding(.vertical, 10)
                
                Form{
                    Section ("Ip address"){
                        HStack(spacing: 5){
                            TextField(text: $first) {
                                Text("00")
                                    .font(.title2)
                            }.keyboardType(.numberPad)
                            
                            Text(".")
                                .padding(.horizontal)
                            
                            TextField(text: $second) {
                                Text("00")
                                    .font(.title2)
                            }.keyboardType(.numberPad)
                            
                            Text(".")
                                .padding(.horizontal)
                            
                            TextField(text: $third) {
                                Text("00")
                                    .font(.title2)
                            }.keyboardType(.numberPad)
                            
                            Text(".")
                                .padding(.horizontal)
                            
                            TextField(text: $fourth) {
                                Text("00")
                                    .font(.title2)
                            }.keyboardType(.numberPad)
                            
                        }
                    }
                    
                    Section ("Port number"){
                        TextField(text: $port) {
                            Text("Port number")
                                .font(.title2)
                        }.keyboardType(.numberPad)
                    }
                }
                
                Button {
                    
                    appModelServer.address = first + "." + second + "." + third + "." + fourth
                    appModelServer.port = port
                    
                    openWindow(id: WindowIDs.xRayFeedWindowID)
                    dismissWindow(id: WindowIDs.inputAddressWindowID)
                } label: {
                    Text("Connect")
                        .font(.title2)
                }
                
            }
            .padding(20)
        }
        .onAppear { appModelServer.isInputWindowOpen = true }
        .onDisappear { appModelServer.isInputWindowOpen = false }
        .glassBackgroundEffect()
    }
}
