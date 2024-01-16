/*
Vishnu Sreekanth

Cricket Scorekeeper

ByesView.swift
 
View that displays as a sheet view when the bye button in ScoringView is
tapped. Asks for additonal information about the bye, and when confirm
is tapped, uses DataController's updateMatchScoreMethod to update the score
with the bye and saves the changes, dismissing and returning to ScoringView.
*/

import SwiftUI

struct ByesView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var runsTaken: String = ""
    @State private var allFieldsNotFilled = false
    @State var nextBowlerViewShowing = false
    @State var outcome = Outcome.bye
    var match: FetchedResults<Match>.Element
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Bye")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                    Spacer()
                }
                VStack {
                    Text("Runs Taken:")
                    Menu {
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
                HStack {
                    Spacer()
                }
                .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 25))
                HStack {
                    Button(action: {
                        if (match.firstInningsFinished) {
                            if (runsTaken.isEmpty) {
                                allFieldsNotFilled = true
                            } else if ((Int64(runsTaken) ?? 0) + (match.teamBowlingFirst?.runs ?? -1) > (match.teamBattingFirst?.runs ?? -1) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                sheetManager.matchCompletedViewShowing = true
                            } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                sheetManager.nextBowlerViewShowing = true
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.bye, secondaryOutcome: Int(runsTaken), offTheBat: false, context: managedObjectContext)
                                sheetManager.byesViewShowing = false
                                dismiss()
                            }
                        } else {
                            if (runsTaken.isEmpty) {
                                allFieldsNotFilled = true
                            } else if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                sheetManager.inningsSwitchViewShowing = true
                            } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                sheetManager.nextBowlerViewShowing = true
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.bye, secondaryOutcome: Int(runsTaken), offTheBat: false, context: managedObjectContext)
                                sheetManager.byesViewShowing = false
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
                        Text("Please specify the number of runs taken.")
                    }
                    Button(action: {
                        sheetManager.byesViewShowing = false
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
            NextBowlerView(outcome: $outcome, offTheBat: false, match: match, secondaryOutcome: Int(runsTaken))
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $sheetManager.inningsSwitchViewShowing) {
            InningsSwitchView(outcome: $outcome, offTheBat: true, match: match, secondaryOutcome: Int(runsTaken))
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $sheetManager.matchCompletedViewShowing) {
            MatchCompletedView(outcome: $outcome, offTheBat: true, match: match, secondaryOutcome: Int(runsTaken))
                .interactiveDismissDisabled(true)
        }
    }
}

/*
 #Preview {
 ByesView()
 }
 */
