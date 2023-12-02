//
//  AboutView.swift
//  DrawingApp
//
//  Created by Martin Krcma on 02.12.2023.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            
            AnimatedBackgroundView()
            
            VStack {
                
                Spacer()
                
                VStack {
                    Image("icon_image")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    Text("Draw it!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 8)
                        .foregroundColor(.black)
                        .shadow(color: .white, radius: 3)
                    
                    Text("version: 0.1.0")
                        .italic()
                        .foregroundColor(.black)
                        .shadow(color: .white, radius: 3)
                    
                    HStack {
                        Text("Created by")
                            .foregroundColor(.black)
                            .shadow(color: .white, radius: 3)
                        Text("0xM4R71N")
                            .foregroundColor(.black)
                            .bold()
                            .shadow(color: .white, radius: 3)
                    }
                    
                    HStack(spacing: 16) {
                        Link(destination: URL(string: "mailto:martin.krcma1@gmail.com")!) {
                            Image("email_icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .shadow(color: .white, radius: 3)
                        }
                        
                        Link(destination: URL(string: "https://www.instagram.com/0xm4r71n/")!) {
                            Image("instagram_icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .shadow(color: .white, radius: 3)
                        }
                        
                        Link(destination: URL(string: "https://github.com/0xMartin")!) {
                            Image("github_icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .shadow(color: .white, radius: 3)
                        }
                    }
                    .padding(.top, 16)
                }
                
                Spacer()
            }
        }
    }
    
}
