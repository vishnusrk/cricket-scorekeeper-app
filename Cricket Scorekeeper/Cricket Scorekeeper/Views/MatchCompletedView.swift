/*
Vishnu Sreekanth

Cricket Scorekeeper

MatchCompletedView.swift
 
When both innings of a match are finished, this view automatically
displays as a sheet view, asking for the user to confirm if they
would like to finish the match. Uses DataController's updateMatchScore
and completeMatch to update and complete the match and save changes
accordingly.
*/

import SwiftUI

struct MatchCompletedView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var outcome: Outcome
    var offTheBat: Bool
    @ObservedObject var match: FetchedResults<Match>.Element
    var secondaryOutcome: Int?
    var outString: String?
    var wicketWasWide: Bool?
    var playerThatGotOut: UUID?
    var newBatter: UUID?
    var crossedOver: Bool?
    var fielderResponsible: UUID?
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Complete Match")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 25, bottom: 10, trailing: 0))
                    Spacer()
                }
                HStack {
                    Button(action: {
                        if (outcome == Outcome.wicket) {
                            DataController.shared.updateMatchScore(match: match, outcome: Outcome.wicket, secondaryOutcome: secondaryOutcome, outString: outString, offTheBat: offTheBat, wicketWasWide: wicketWasWide!, playerThatGotOut: playerThatGotOut, newBatter: nil, crossedOver: crossedOver!, fielderResponsible: fielderResponsible, newBowler: nil, context: managedObjectContext)
                        } else if (outcome == Outcome.bye || outcome == Outcome.legBye || outcome == Outcome.wide || outcome == Outcome.noBall) {
                            DataController.shared.updateMatchScore(match: match, outcome: outcome, secondaryOutcome: secondaryOutcome, offTheBat: offTheBat, newBowler: nil, context: managedObjectContext)
                        } else {
                            DataController.shared.updateMatchScore(match: match, outcome: outcome, offTheBat: offTheBat, newBowler: nil, context: managedObjectContext)
                        }
                        DataController.shared.completeMatch(match: match, context: managedObjectContext)
                        sheetManager.byesViewShowing = false
                        sheetManager.legByesViewShowing = false
                        sheetManager.wicketsViewShowing = false
                        sheetManager.widesViewShowing = false
                        sheetManager.noBallViewShowing = false
                        sheetManager.matchCompletedViewShowing = false
                        dismiss()
                        
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
                    Button(action: {
                        sheetManager.matchCompletedViewShowing = false
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
    }
}

/*
 #Preview {
 MatchCompletedView()
 }
 */
