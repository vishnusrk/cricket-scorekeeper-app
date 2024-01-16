/*
Vishnu Sreekanth

Cricket Scorekeeper

WicketView.swift
 
View that displays as a sheet view when the wicket button in ScoringView
is tapped. Asks for additonal information about the wicket, and when confirm
is tapped, uses DataController's updateMatchScoreMethod to update the score
with the wicket and saves the changes, dismissing and returning to ScoringView.
*/

import SwiftUI

struct WicketView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var batterDismissed: String = ""
    @State private var batterDismissedId: UUID = UUID()
    @State private var modeOfDismissal: String = ""
    @State private var fielderResponsible: String = ""
    @State private var fielderResponsibleId: UUID = UUID()
    @State private var wideDelivery: Bool = false
    @State private var crossedOver: Bool = false
    @State private var batterHitBall: Bool = false
    @State private var runsTaken: String = ""
    @State var nextBatter: String = ""
    @State var nextBatterId: UUID? = nil
    @State private var allFieldsNotFilled = false
    @State var nextBowlerViewShowing = false
    @State var outcome = Outcome.wicket
    var match: FetchedResults<Match>.Element
    var body: some View {
        let battingTeamArray = match.currentBattingTeam?.players?.compactMap { $0 as? Player } ?? []
        let bowlingTeamArray = match.currentBowlingTeam?.players?.compactMap { $0 as? Player } ?? []
        NavigationView {
            VStack {
                HStack {
                    Text("Wicket")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                    Spacer()
                }
                VStack {
                    Text("Batter Dismissed:")
                    Menu {
                        Button(
                            action: {
                                batterDismissed = match.striker?.name ?? "N/A"
                                batterDismissedId = match.striker?.id ?? UUID()
                            },
                            label: {Text("\(match.striker?.name ?? "N/A")")}
                        )
                        Button(
                            action: {
                                batterDismissed = match.nonStriker?.name ?? "N/A"
                                batterDismissedId = match.nonStriker?.id ?? UUID()
                            },
                            label: {Text("\(match.nonStriker?.name ?? "N/A")")}
                        )
                    } label: {
                        Label (
                            title: {
                                Text("\(batterDismissed)")
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .fontWeight(.bold)
                            },
                            icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                        )
                    }
                }
                .padding()
                VStack {
                    Text("Mode of Dismissal:")
                    Menu {
                        Button(
                            action: {
                                modeOfDismissal = "Caught"
                            },
                            label: {Text("Caught")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "Bowled"
                            },
                            label: {Text("Bowled")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "LBW"
                            },
                            label: {Text("LBW")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "Stumped"
                            },
                            label: {Text("Stumped")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "Run Out"
                            },
                            label: {Text("Run Out")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "Hit Wicket"
                            },
                            label: {Text("Hit Wicket")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "Retired Out"
                            },
                            label: {Text("Retired Out")}
                        )
                        Button(
                            action: {
                                modeOfDismissal = "Retired Hurt"
                            },
                            label: {Text("Retired Hurt")}
                        )
                    } label: {
                        Label (
                            title: {
                                Text("\(modeOfDismissal)")
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .fontWeight(.bold)
                            },
                            icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                        )
                    }
                }
                .padding()
                if (modeOfDismissal == "Caught" || modeOfDismissal == "Stumped" || modeOfDismissal == "Run Out") {
                    VStack {
                        Text("Fielder Responsible:")
                        Menu {
                            ForEach(bowlingTeamArray) { player in
                                if (modeOfDismissal == "Stumped") {
                                    if (match.bowler?.id != player.id) {
                                        Button(
                                            action: {
                                                fielderResponsible = player.name ?? "N/A"
                                                fielderResponsibleId = player.id ?? UUID()
                                                
                                            },
                                            label: {Text("\(player.name ?? "N/A")")}
                                        )
                                    }
                                } else {
                                    Button(
                                        action: {
                                            fielderResponsible = player.name ?? "N/A"
                                            fielderResponsibleId = player.id ?? UUID()
                                            
                                        },
                                        label: {Text("\(player.name ?? "N/A")")}
                                    )
                                }
                            }
                        } label: {
                            Label (
                                title: {
                                    Text("\(fielderResponsible)")
                                        .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                        .fontWeight(.bold)
                                },
                                icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                            )
                        }
                    }
                    .padding()
                }
                if (modeOfDismissal == "Run Out") {
                    VStack {
                        Text("Runs Successfully Taken:")
                        Menu {
                            Button(
                                action: {
                                    runsTaken = "0"
                                },
                                label: {Text("0")}
                            )
                            Button(
                                action: {
                                    runsTaken = "1"
                                },
                                label: {Text("1")}
                            )
                            Button(
                                action: {
                                    runsTaken = "2"
                                },
                                label: {Text("2")}
                            )
                            Button(
                                action: {
                                    runsTaken = "3"
                                },
                                label: {Text("3")}
                            )
                            Button(
                                action: {
                                    runsTaken = "4"
                                },
                                label: {Text("4")}
                            )
                        } label: {
                            Label (
                                title: {
                                    Text("\(runsTaken)")
                                        .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                        .fontWeight(.bold)
                                },
                                icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                            )
                        }
                    }
                    .padding()
                }
                if (modeOfDismissal == "Stumped" ||  modeOfDismissal == "Hit Wicket") {
                    HStack {
                        Toggle("Wide Delivery", isOn: $wideDelivery)
                            .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255)))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 25))
                } else if (modeOfDismissal == "Run Out") {
                    HStack {
                        Toggle("No Ball/Wide Delivery", isOn: $wideDelivery)
                            .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255)))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 25))
                    HStack {
                        Toggle("Batter Hit the Ball", isOn: $batterHitBall)
                            .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255)))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 25))
                }
                if (modeOfDismissal == "Run Out" || modeOfDismissal == "Caught") {
                    HStack {
                        Toggle("Batter Crossed Over", isOn: $crossedOver)
                            .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255)))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 25))
                }
                if (match.currentBattingTeam?.wicketsLost != match.teamSize - 2) {
                    VStack {
                        Text("Next Batter")
                        Menu {
                            ForEach(battingTeamArray) { player in
                                if (player.battingPosition == 0 || player.outDescription == "retired hurt") {
                                    Button(
                                        action: {
                                            nextBatter = player.name ?? "N/A"
                                            nextBatterId = player.id
                                        },
                                        label: {Text("\(player.name ?? "N/A")")}
                                    )
                                }
                            }
                        } label: {
                            Label (
                                title: {
                                    Text("\(nextBatter)")
                                        .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                        .fontWeight(.bold)
                                },
                                icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                            )
                        }
                    }
                    .padding()
                }
                HStack {
                    Button(action: {
                        if (modeOfDismissal.isEmpty || (nextBatter.isEmpty && (match.currentBattingTeam?.wicketsLost != match.teamSize - 2)) || batterDismissed.isEmpty) {
                            allFieldsNotFilled = true
                        }
                        if (modeOfDismissal == "Retired Hurt" && (match.currentBattingTeam?.wicketsLost == match.teamSize - 2)) {
                            allFieldsNotFilled = true
                        }
                        if (batterDismissed == match.nonStriker?.name && (modeOfDismissal != "Run Out" && modeOfDismissal != "Retired Out" && modeOfDismissal != "Retired Hurt")) {
                            allFieldsNotFilled = true
                        }
                        if (modeOfDismissal == "Caught" || modeOfDismissal == "Stumped" || modeOfDismissal == "Run Out") {
                            if (fielderResponsible.isEmpty) {
                                allFieldsNotFilled = true
                            }
                        }
                        if (modeOfDismissal == "Run Out") {
                            if (runsTaken.isEmpty) {
                                allFieldsNotFilled = true
                            }
                        }
                        if (!allFieldsNotFilled) {
                            if (match.firstInningsFinished) {
                                if (!wideDelivery) {
                                    if (modeOfDismissal == "Retired Out" || modeOfDismissal == "Retired Hurt") {
                                        if (match.currentBattingTeam?.wicketsLost == match.teamSize - 2) {
                                            sheetManager.matchCompletedViewShowing = true
                                        } else {
                                            DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, offTheBat: batterHitBall, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId, context: managedObjectContext)
                                            sheetManager.wicketsViewShowing = false
                                            dismiss()
                                        }
                                    } else {
                                        if ((Int64(runsTaken) ?? -1) + (match.teamBowlingFirst?.runs ?? -1) > match.teamBattingFirst?.runs ?? -1 || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2 || match.currentBattingTeam?.wicketsLost == match.teamSize - 2) {
                                            sheetManager.matchCompletedViewShowing = true
                                        } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                            sheetManager.nextBowlerViewShowing = true
                                        } else {
                                            DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, offTheBat: batterHitBall, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId, context: managedObjectContext)
                                            sheetManager.wicketsViewShowing = false
                                            dismiss()
                                        }
                                    }
                                } else {
                                    if (1 + (Int64(runsTaken) ?? -1) + (match.teamBowlingFirst?.runs ?? -1) > match.teamBattingFirst?.runs ?? -1 || match.currentBattingTeam?.wicketsLost == match.teamSize - 2) {
                                        sheetManager.matchCompletedViewShowing = true
                                    } else {
                                        DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, offTheBat: batterHitBall, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId, context: managedObjectContext)
                                        sheetManager.wicketsViewShowing = false
                                        dismiss()
                                    }
                                }
                            } else {
                                if (!wideDelivery) {
                                    if (modeOfDismissal == "Retired Out" || modeOfDismissal == "Retired Hurt") {
                                        if (match.currentBattingTeam?.wicketsLost == match.teamSize - 2) {
                                            sheetManager.inningsSwitchViewShowing = true
                                        } else {
                                            DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, offTheBat: batterHitBall, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId, context: managedObjectContext)
                                            sheetManager.wicketsViewShowing = false
                                            dismiss()
                                        }
                                    } else {
                                        if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2 || match.currentBattingTeam?.wicketsLost == match.teamSize - 2) {
                                            sheetManager.inningsSwitchViewShowing = true
                                        } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                            sheetManager.nextBowlerViewShowing = true
                                        } else {
                                            DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, offTheBat: batterHitBall, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId, context: managedObjectContext)
                                            sheetManager.wicketsViewShowing = false
                                            dismiss()
                                        }
                                    }
                                } else {
                                    if (match.currentBattingTeam?.wicketsLost == match.teamSize - 2) {
                                        sheetManager.inningsSwitchViewShowing = true
                                    } else {
                                        DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, offTheBat: batterHitBall, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId, context: managedObjectContext)
                                        sheetManager.wicketsViewShowing = false
                                        dismiss()
                                    }
                                }
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
                        if (modeOfDismissal == "Retired Hurt" && (match.currentBattingTeam?.wicketsLost == match.teamSize - 2)) {
                            Text("Since there is only one wicket left, if the batter is retired hurt, please select retired out as there are no other batters left.")
                        } else if (batterDismissed == match.nonStriker?.name && modeOfDismissal != "Run Out") {
                            Text("The only ways the non striker can get out on a delivery are run out and retired out/hurt.")
                        } else {
                            Text("Please fill all of the fields.")
                        }
                    }
                    Button(action: {
                        sheetManager.wicketsViewShowing = false
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
        .sheet(isPresented: $sheetManager.nextBowlerViewShowing) {
            NextBowlerView(outcome: $outcome, offTheBat: batterHitBall, match: match, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId)
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $sheetManager.inningsSwitchViewShowing) {
            InningsSwitchView(outcome: $outcome, offTheBat: batterHitBall, match: match, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId)
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $sheetManager.matchCompletedViewShowing) {
            MatchCompletedView(outcome: $outcome, offTheBat: batterHitBall, match: match, secondaryOutcome: Int(runsTaken), outString: modeOfDismissal, wicketWasWide: wideDelivery, playerThatGotOut: batterDismissedId, newBatter: nextBatterId, crossedOver: crossedOver, fielderResponsible: fielderResponsibleId)
                .interactiveDismissDisabled(true)
        }
        
    }
}

/*
 #Preview {
 WicketView()
 }
 */
