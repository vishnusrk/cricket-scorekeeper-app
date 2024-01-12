/*
Vishnu Sreekanth

Cricket Scorekeeper

InningsSwitchView.swift
 
When an innings is finished, this view automatically displays as a sheet view,
asking for information needed to start the next innings, similar to the
information asked for by StartMatchView. Uses DataController's updateMatchScore
and switchInnings to update the match and save changes accordingly.
*/

import SwiftUI

struct InningsSwitchView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var allFieldsNotFilled = false
    @Binding var outcome: Outcome
    var overthrow: Bool
    var offTheBat: Bool
    var match: FetchedResults<Match>.Element
    var secondaryOutcome: Int?
    var outString: String?
    var wicketWasWide: Bool?
    var playerThatGotOut: UUID?
    var newBatter: UUID?
    var crossedOver: Bool?
    var fielderResponsible: UUID?
    @State var striker = ""
    @State var strikerId: UUID? = nil
    @State var nonStriker = ""
    @State var nonStrikerId: UUID? = nil
    @State var bowler = ""
    @State var bowlerId: UUID? = nil
    var body: some View {
        let battingTeam = match.currentBattingTeam?.name
        let battingTeamArray = match.currentBattingTeam?.players?.compactMap { $0 as? Player } ?? []
        let bowlingTeam = match.currentBowlingTeam?.name
        let bowlingTeamArray = match.currentBowlingTeam?.players?.compactMap { $0 as? Player } ?? []
        NavigationView {
            VStack {
                HStack {
                    Text("Second Innings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                    Spacer()
                }
                VStack {
                    Text("Striker (\(bowlingTeam ?? ""))")
                        .multilineTextAlignment(.center)
                    Menu {
                        ForEach(bowlingTeamArray) { player in
                            if let unwrappedUUID = nonStrikerId {
                                if (unwrappedUUID != player.id){
                                    Button(
                                        action: {
                                            striker = player.name ?? "N/A"
                                            strikerId = player.id
                                        },
                                        label: {Text("\(player.name ?? "N/A")")}
                                    )
                                }
                            } else {
                                Button(
                                    action: {
                                        striker = player.name ?? "N/A"
                                        strikerId = player.id
                                    },
                                    label: {Text("\(player.name ?? "N/A")")}
                                )
                            }
                        }
                    } label: {
                        Label (
                            title: {
                                Text("\(striker)")
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .fontWeight(.bold)
                            },
                            icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                        )
                    }
                }
                .padding()
                VStack {
                    Text("Non Striker (\(bowlingTeam ?? ""))")
                        .multilineTextAlignment(.center)
                    Menu {
                        ForEach(bowlingTeamArray) { player in
                            if let unwrappedUUID = strikerId {
                                if (unwrappedUUID != player.id){
                                    Button(
                                        action: {
                                            nonStriker = player.name ?? "N/A"
                                            nonStrikerId = player.id
                                        },
                                        label: {Text("\(player.name ?? "N/A")")}
                                    )
                                }
                            } else {
                                Button(
                                    action: {
                                        nonStriker = player.name ?? "N/A"
                                        nonStrikerId = player.id
                                    },
                                    label: {Text("\(player.name ?? "N/A")")}
                                )
                            }
                        }
                    } label: {
                        Label (
                            title: {
                                Text("\(nonStriker)")
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .fontWeight(.bold)
                            },
                            icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                        )
                    }
                }
                .padding()
                VStack {
                    Text("Opening Bowler (\(battingTeam ?? ""))")
                        .multilineTextAlignment(.center)
                    Menu {
                        ForEach(battingTeamArray) { player in
                            Button(
                                action: {
                                    bowler = player.name ?? "N/A"
                                    bowlerId = player.id
                                },
                                label: {Text("\(player.name ?? "N/A")")}
                            )
                        }
                    } label: {
                        Label (
                            title: {
                                Text("\(bowler)")
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .fontWeight(.bold)
                            },
                            icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                        )
                    }
                }
                .padding()
                HStack {
                    Button(action: {
                        Task {
                            if (striker.isEmpty || nonStriker.isEmpty || bowler.isEmpty) {
                                allFieldsNotFilled = true
                            } else {
                                if (outcome == Outcome.wicket) {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: secondaryOutcome, outString: outString, offTheBat: offTheBat, wicketWasWide: wicketWasWide!, playerThatGotOut: playerThatGotOut, newBatter: nil, crossedOver: crossedOver!, fielderResponsible: fielderResponsible, newBowler: nil, context: managedObjectContext)
                                } else if (outcome == Outcome.bye || outcome == Outcome.legBye) {
                                    DataController.shared.updateMatchScore(match: match, outcome: outcome, secondaryOutcome: secondaryOutcome, overthrow: overthrow, offTheBat: offTheBat, newBowler: nil, context: managedObjectContext)
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: outcome, overthrow: overthrow, offTheBat: offTheBat, newBowler: nil, context: managedObjectContext)
                                }
                                DataController.shared.switchInnings(match: match, striker: strikerId, nonStriker: nonStrikerId, bowler: bowlerId, context: managedObjectContext)
                                sheetManager.byesViewShowing = false
                                sheetManager.legByesViewShowing = false
                                sheetManager.wicketsViewShowing = false
                                sheetManager.inningsSwitchViewShowing = false
                                dismiss()
                            }
                        }
                    }) {
                        Text("Confirm")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 175)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .cornerRadius(10)
                    }
                    .alert("Error", isPresented: $allFieldsNotFilled) {
                        Button("OK", role: .cancel) {
                            allFieldsNotFilled = false
                        }
                    } message: {
                        Text("Please fill all of the fields.")
                    }
                    Button(action: {
                        sheetManager.inningsSwitchViewShowing = false
                        dismiss()
                    }) {
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
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

/*
 #Preview {
 InningsSwitchView()
 }
 */
