/*
Vishnu Sreekanth

Cricket Scorekeeper

WidesView.swift
 
View that displays as a sheet view when the wide button in ScoringView is tapped.
Asks for additonal information about the wide, and when confirm is tapped, uses
DataController's updateMatchScoreMethod to update the score with the wide and
saves the changes, dismissing and returning to ScoringView.
*/

import SwiftUI

struct WidesView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var runsTaken: String = ""
    @State private var allFieldsNotFilled = false
    @State var outcome = Outcome.wide
    var match: FetchedResults<Match>.Element
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Wide")
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
                HStack {
                    Spacer()
                }
                .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 25))
                HStack {
                    Button(action: {
                        let x = (1 + Int64(Int(runsTaken) ?? -1) + (match.teamBowlingFirst?.runs ?? -1))
                        if (match.firstInningsFinished) {
                            if (runsTaken.isEmpty) {
                                allFieldsNotFilled = true
                            } else if (x > (match.teamBattingFirst?.runs ?? -1)) {
                                sheetManager.matchCompletedViewShowing = true
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.wide, secondaryOutcome: Int(runsTaken), offTheBat: false, context: managedObjectContext)
                                sheetManager.widesViewShowing = false
                                dismiss()
                            }
                        } else {
                            if (runsTaken.isEmpty) {
                                allFieldsNotFilled = true
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.wide, secondaryOutcome: Int(runsTaken), offTheBat: false, context: managedObjectContext)
                                sheetManager.widesViewShowing = false
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
                        sheetManager.widesViewShowing = false
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
        .sheet(isPresented: $sheetManager.matchCompletedViewShowing) {
            MatchCompletedView(outcome: $outcome, offTheBat: false, match: match, secondaryOutcome: Int(runsTaken))
                .interactiveDismissDisabled(true)
        }
    }
}

/*
#Preview {
    WidesView()
}
*/
