/*
Vishnu Sreekanth

Cricket Scorekeeper

AboutView.swift
 
View accessed from MainView that displays information about the app.
*/

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                Button(action: {dismiss()}) {
                    HStack {
                        Image(systemName: "chevron.left").padding(.trailing, -5)
                        Text("Back")
                        Spacer()
                    }
                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                }
                .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 0))
                HStack {
                    Text("Welcome to Cricket Scorekeeper!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 15, leading: 25, bottom: 20, trailing: 0))
                    Spacer()
                }
                HStack {
                    Text("Cricket Scorekeeper is a convenient cricket scorekeeping app that lets you efficiently score matches while they’re being played. It’s designed for those who play cricket casually and want to keep the scores of their matches in an organized fashion, but it can also be used for more formal matches as well. The convenience of being able to track and quickly update a score with simple button presses on a portable device takes away the burden of having to memorize scores or the hassle of typing/using pencil and paper. The matches/scorecards are saved to your device, so you can leave the app and resume your matches whenever you desire. Even when matches are finished, their scorecards are kept and can be viewed anytime.")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("To create a match, go back to the main menu, and tap My Matches. Then, tap the + button in the top right. From there, follow the instructions and fill all of the fields, and your match will be up and running in no time!")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("Notes:")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("- Whenever a wicket occurs (even if it’s on a wide delivery), tap the wicket button (W).")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("- If a no-ball occurs and it doesn't result in a run out, tap the no ball button (nb). If it's a run out, tap W.")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("- In the scoring menu, the undo button is the button with the undo arrow on the bottom right. It removes the previous delivery as if it never happened. However, after a wicket falls or an over is finished, previous deliveries cannot be undone. Please be absolutely sure of the wicket or over switch before you confirm it.")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("- Cricket Scorekeeper currently does not support DLS/shortened innings or Impact Players.")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("- Timed out dismissals are currently not supported.")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("Have fun!")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 15, trailing: 25))
                    Spacer()
                }
                HStack {
                    Text("This app was developed by Vishnu Sreekanth.")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 25))
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    AboutView()
}
