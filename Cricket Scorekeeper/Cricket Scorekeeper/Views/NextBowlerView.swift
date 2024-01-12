/*
Vishnu Sreekanth

Cricket Scorekeeper

NextBowlerView.swift
 
When an over is finished, this view automatically displays as a sheet view,
asking for the next bowler. Uses DataController's  updateMatchScore to update
the match and save changes accordingly.
*/

import SwiftUI

struct NextBowlerView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var nextBowler: String = ""
    @State private var nextBowlerId: UUID = UUID()
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
    var body: some View {
        let bowlingTeamArray = match.currentBowlingTeam?.players?.compactMap { $0 as? Player } ?? []
        NavigationView {
            VStack {
                HStack {
                    Text("Next Bowler")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                    Spacer()
                }
                Menu {
                    ForEach(bowlingTeamArray) { player in
                        if (player != match.bowler) {
                            Button(
                                action: {
                                    nextBowler = player.name ?? ""
                                    nextBowlerId = player.id ?? UUID()
                                },
                                label: {Text("\(player.name ?? "N/A")")}
                            )
                        }
                    }
                } label: {
                    Label (
                        title: {
                            Text("\(nextBowler)")
                                .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                .fontWeight(.bold)
                        },
                        icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                    )
                }
                .padding()
                HStack {
                    Button(action: {
                        if (nextBowler.isEmpty) {
                            allFieldsNotFilled = true
                        } else {
                            if (outcome == Outcome.wicket) {
                                DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: secondaryOutcome, outString: outString, offTheBat: offTheBat, wicketWasWide: wicketWasWide!, playerThatGotOut: playerThatGotOut, newBatter: newBatter, crossedOver: crossedOver!, fielderResponsible: fielderResponsible, newBowler: nextBowlerId, context: managedObjectContext)
                            } else if (outcome == Outcome.bye || outcome == Outcome.legBye) {
                                DataController.shared.updateMatchScore(match: match, outcome: outcome, secondaryOutcome: secondaryOutcome, overthrow: overthrow, offTheBat: offTheBat, newBowler: nextBowlerId, context: managedObjectContext)
                            } else {
                                DataController.shared.updateMatchScore(match: match, outcome: outcome, overthrow: overthrow, offTheBat: offTheBat, newBowler: nextBowlerId, context: managedObjectContext)
                            }
                            try? managedObjectContext.save()
                            sheetManager.byesViewShowing = false
                            sheetManager.legByesViewShowing = false
                            sheetManager.wicketsViewShowing = false
                            sheetManager.nextBowlerViewShowing = false
                            dismiss()
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
                        Text("Please specify the bowler for the new over.")
                    }
                    Button(action: {
                        sheetManager.nextBowlerViewShowing = false
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
 NextBowlerView()
 }
 */
