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
    
    @Environment(\.setMode) private var setMode
    
    @State private var address: String = ""
    @State private var port: String = ""
    
    var body: some View {
        VStack{
            Text("Input information to connect")
                .font(.title)
                .padding(.vertical, 10)
            
            Form{
                Section ("Ip address"){
                    TextField(text: $address) {
                        Text("Ip address")
                            .font(.title2)
                    }
                }
                
                Section ("Port number"){
                    TextField(text: $port) {
                        Text("Port number")
                            .font(.title2)
                    }
                }
            }
            
            Button {
                Task{
                    await setMode(.open2DWindow, nil)
                }
            } label: {
                Text("Connect")
                    .font(.title2)
            }

            
        }.padding(20)
        .glassBackgroundEffect()
    }
}
