/*
Vishnu Sreekanth

Cricket Scorekeeper

MatchCreationView.swift
 
View where a match is created, accessed through the + button in 
MatchesView. Has fields asking for information about the match, and
when Confirm is tapped, it uses the createMatch method in
DataController.swift to create the match and save it to CoreData,
passing on the information in the fields.
*/

import SwiftUI
import CoreData

struct MatchCreationView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var overs: Double = 1
    @State private var teamSize: Double = 11
    @State private var teamOneName = ""
    @State private var teamTwoName = ""
    @State private var teamOnePlayerNames = Array(repeating: "", count: 11)
    @State private var teamTwoPlayerNames = Array(repeating: "", count: 11)
    @State private var matchCreated = false
    @State private var allFieldsNotFilled = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("New Match")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                            .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                        Spacer()
                    }
                    VStack {
                        Text("Overs: \(Int(overs))")
                        Slider(value: $overs, in: 1...90, step: 1)
                            .accentColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                    }
                    .padding()
                    VStack {
                        Text("Team Size: \(Int(teamSize))")
                        Slider(value: $teamSize, in: 2...11, step: 1)
                            .accentColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                    }
                    .padding()
                    HStack {
                        Text("Team 1: ")
                        TextField("Team 1 Name", text: $teamOneName)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 165/255, green: 165/255, blue: 165/255) : Color(red: 155/255, green: 155/255, blue: 155/255), lineWidth: 1)
                            )
                            .autocorrectionDisabled(true)
                    }
                    .padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25))
                    HStack {
                        Text("Team 2: ")
                        TextField("Team 2 Name", text: $teamTwoName)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 165/255, green: 165/255, blue: 165/255) : Color(red: 155/255, green: 155/255, blue: 155/255), lineWidth: 1)
                            )
                            .autocorrectionDisabled(true)
                    }
                    .padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25))
                    HStack {
                        VStack {
                            Text("Team 1")
                            ForEach(0..<Int(teamSize), id: \.self) { index in
                                TextField("Player Name", text: $teamOnePlayerNames[index])
                                    .textFieldStyle(.roundedBorder)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(colorScheme == .dark ? Color(red: 165/255, green: 165/255, blue: 165/255) : Color(red: 155/255, green: 155/255, blue: 155/255), lineWidth: 1)
                                    )
                                    .autocorrectionDisabled(true)
                            }
                        }
                        VStack {
                            Text("Team 2")
                            ForEach(0..<Int(teamSize), id: \.self) { index in
                                TextField("Player Name", text: $teamTwoPlayerNames[index])
                                    .textFieldStyle(.roundedBorder)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(colorScheme == .dark ? Color(red: 165/255, green: 165/255, blue: 165/255) : Color(red: 155/255, green: 155/255, blue: 155/255), lineWidth: 1)
                                    )
                                    .autocorrectionDisabled(true)
                            }
                        }
                    }
                    .padding()
                    HStack {
                        Button("Create Match") {
                            if (teamOneName.isEmpty || teamTwoName.isEmpty || !allPlayersEntered() || teamOneName == teamTwoName) {
                                allFieldsNotFilled = true
                            } else {
                                DataController.shared.createMatch(overs: Int64(overs), teamSize: Int64(teamSize), teamOneName: teamOneName, teamTwoName: teamTwoName, teamOnePlayerNames: teamOnePlayerNames, teamTwoPlayerNames: teamTwoPlayerNames, context: managedObjectContext)
                                matchCreated = true
                                dismiss()
                            }
                        }
                        .alert("Error", isPresented: $allFieldsNotFilled) {
                            Button("OK", role: .cancel) {
                                allFieldsNotFilled = false
                            }
                        } message: {
                            if (teamOneName == teamTwoName) {
                                Text("Both teams cannot have the same name.")
                            } else {
                                Text("Please fill all of the fields.")
                            }
                        }
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 175)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .cornerRadius(10)
                        Button(action: {dismiss()}){
                            Text("Cancel")
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .frame(width: 175)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                .cornerRadius(10)
                        }
                    }
                }
            }.navigationDestination(isPresented: $matchCreated) {
                MatchesView()
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    private func allPlayersEntered() -> Bool {
        for i in 0...Int(teamSize - 1) {
            if (teamOnePlayerNames[i].isEmpty) {
                return false
            }
            if (teamTwoPlayerNames[i].isEmpty) {
                return false
            }
        }
        return true
    }
    
}

#Preview {
    MatchCreationView()
}
