/*
Vishnu Sreekanth

Cricket Scorekeeper

NoBallView.swift
 
View that displays as a sheet view when the no ball button in ScoringView is
tapped. Asks for additonal information about the no ball, and when confirm
is tapped, uses DataController's updateMatchScoreMethod to update the score
with the no ball and saves the changes, dismissing and returning to ScoringView.
*/

import SwiftUI

struct NoBallView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var overthrow: Bool
    @State private var runsTaken: String = ""
    @State private var batterHitBall: Bool = false
    @State private var allFieldsNotFilled = false
    @State var outcome = Outcome.noBall
    var match: FetchedResults<Match>.Element
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("No Ball")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
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
                        Button(
                            action: {
                                runsTaken = "6"
                            },
                            label: {Text("6")}
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
                    Toggle("Overthrow to Boundary", isOn: $overthrow)
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
                HStack {
                    Button(action: {
                        let x = (5 + Int64(Int(runsTaken) ?? -1) + (match.teamBowlingFirst?.runs ?? -1))
                        let overthrowCondition: Bool = overthrow && (x > match.teamBattingFirst?.runs ?? -1)
                        let y = (1 + Int64(Int(runsTaken) ?? -1) + (match.teamBowlingFirst?.runs ?? -1))
                        if (match.firstInningsFinished) {
                            if (runsTaken.isEmpty || (runsTaken == "6" && !batterHitBall)) {
                                allFieldsNotFilled = true
                            } else if (overthrowCondition || y > (match.teamBattingFirst?.runs ?? -1)) {
                                sheetManager.matchCompletedViewShowing = true
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.noBall, secondaryOutcome: Int(runsTaken), overthrow: overthrow, offTheBat: batterHitBall, context: managedObjectContext)
                                overthrow = false
                                sheetManager.noBallViewShowing = false
                                dismiss()
                            }
                        } else {
                            if (runsTaken.isEmpty || (runsTaken == "6" && !batterHitBall)) {
                                allFieldsNotFilled = true
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.noBall, secondaryOutcome: Int(runsTaken), overthrow: overthrow, offTheBat: batterHitBall, context: managedObjectContext)
                                overthrow = false
                                sheetManager.noBallViewShowing = false
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
                        if (runsTaken == "6" && !batterHitBall) {
                            Text("A 6 can't happen if the batter didn't hit the ball!")
                        } else {
                            Text("Please specify the number of runs taken.")
                        }
                    }
                    Button(action: {
                        overthrow = false
                        sheetManager.noBallViewShowing = false
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
            MatchCompletedView(outcome: $outcome, overthrow: overthrow, offTheBat: batterHitBall, match: match, secondaryOutcome: Int(runsTaken))
                .interactiveDismissDisabled(true)
        }
    }
}

/*
 #Preview {
 NoBallView()
 }
 */
