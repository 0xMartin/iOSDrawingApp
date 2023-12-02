//
//  ContentView.swift
//  DrawingApp
//
//  Created by Martin Krcma on 30.11.2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            ZStack {
                
                AnimatedBackgroundView()
                
                VStack {
                    Spacer()
                    
                    VStack {
                        Image("icon_image")
                            .resizable()
                            .frame(width: 120, height: 120)
                        Text("Draw it!")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top, 8)
                            .foregroundColor(.black)
                            .shadow(color: .white, radius: 4)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: DrawingView()){
                            Label("Create New", systemImage: "plus.circle")
                                .padding()
                                .bold()
                                .frame(minWidth: 160)
                                .foregroundColor(.black)
                                .background(Color.red)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 6)
                                )
                        }
                        
                        NavigationLink(destination: LoadImageView()) {
                            Label("Load Image", systemImage: "photo")
                                .padding()
                                .bold()
                                .frame(minWidth: 160)
                                .foregroundColor(.black)
                                .background(Color.orange)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 6)
                                )
                        }
                        
                        NavigationLink(destination: AboutView()) {
                            Label("About", systemImage: "info.circle")
                                .padding()
                                .bold()
                                .frame(minWidth: 160)
                                .foregroundColor(.black)
                                .background(Color.yellow)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 6)
                                )
                        }
                    }
                    
                    Spacer()
                    
                }
                .navigationBarHidden(true)
                
            }
        }
    }
    
}
