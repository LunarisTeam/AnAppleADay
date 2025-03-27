//
//  ControlPanel.swift
//  AnAppleADay
//
//  Created by Marzia Pirozzi on 27/03/25.
//

import Foundation
import SwiftUI
import RealityKit

struct controlPanel: View {
    
    var bonesEntity: Entity
    var arteriesEntity: Entity
    @Binding var scale: Bool
    
    var body: some View {
        
        
        //          VStack{
        //              Button {
        //                  bonesEntity.isEnabled.toggle()
        //                  arteriesEntity.isEnabled.toggle()
        //
        //                  if(!bonesEntity.isEnabled){
        //                      arteriesEntity.position = bonesEntity.position
        //                      arteriesEntity.scale = bonesEntity.scale
        //                  }else{
        //                      bonesEntity.position = arteriesEntity.position
        //                      bonesEntity.scale = arteriesEntity.scale
        //                  }
        //
        //
        //              } label: {
        //                  Text("Toggle Bones/Arteries")
        //                      .font(.title)
        //              }
        //
        //
        //              Button {
        //                  scale.toggle()
        //                  if(scale){
        //                      bonesEntity.scale *= 2.0
        //                      arteriesEntity.scale *= 2.0
        //                  }else{
        //                      bonesEntity.scale /= 2.0
        //                      arteriesEntity.scale /= 2.0
        //                  }
        //              } label: {
        //                  Text("Scale model")
        //                      .font(.title)
        //              }
        //
        //
        //          }.padding(10)
        //              .glassBackgroundEffect()
        //
        
        HStack{
            //toggle bones arteries
            Button {
                bonesEntity.isEnabled.toggle()
                arteriesEntity.isEnabled.toggle()
                
                if(!bonesEntity.isEnabled){
                    arteriesEntity.position = bonesEntity.position
                    arteriesEntity.scale = bonesEntity.scale
                }else{
                    bonesEntity.position = arteriesEntity.position
                    bonesEntity.scale = arteriesEntity.scale
                }
            } label: {
                Image("hideBones")
            }
            
            //scale
            Button {
                scale.toggle()
                if(scale){
                    bonesEntity.scale *= 2.0
                    arteriesEntity.scale *= 2.0
                }else{
                    bonesEntity.scale /= 2.0
                    arteriesEntity.scale /= 2.0
                }
            } label: {
                Image("RestoreSize")
            }
            
            //lock in position
            Button {
                
            } label: {
                Image("lockInPosition")
            }
            
            //Divider
//            Divider().frame(maxHeight: .infinity)
            
            //2D
            Button {
                
            } label: {
                Image("connect2D")
            }
            
            //lock2D
            Button {
                
            } label: {
                Image("lock2dù")
            }
            
            //LOCKINTO3D2
            Button {
                
            } label: {
                Image("LOCKINTO3D2")
            }
        }.padding(.vertical, 20)
            .padding(.horizontal, 30)
        .glassBackgroundEffect()
        
        
    }
}
