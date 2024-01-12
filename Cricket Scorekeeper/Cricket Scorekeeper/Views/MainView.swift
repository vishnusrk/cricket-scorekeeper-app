/*
Vishnu Sreekanth

Cricket Scorekeeper

MainView.swift
 
Main view of the app that displays when the app is opened. Can navigate to
MatchesView or AboutView from here using the two respectively labeled buttons
at the bottom.
*/

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var isIconRotating = false
    var body: some View {
        NavigationView {
            VStack {
                Text("Cricket Scorekeeper")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
                Spacer()
                Image(colorScheme == .dark ? "CricketBallIcon" : "CricketBallIcon2")
                    .resizable()
                    .frame(width: 250.0, height: 250.0)
                    .rotationEffect(.degrees(isIconRotating ? 360 : 0))
                    .animation(.easeInOut(duration: 1), value: isIconRotating)
                    .onTapGesture {
                        isIconRotating.toggle()
                    }
                Spacer()
                VStack {
                    NavigationLink(destination: MatchesView().environment(\.managedObjectContext, managedObjectContext)){
                        Text("My Matches")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 300.0)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: AboutView()){
                        Text("About")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 300.0)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                            )
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MainView()
}
