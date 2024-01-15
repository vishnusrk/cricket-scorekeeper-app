/*
Vishnu Sreekanth

Cricket Scorekeeper

ScoringView.swift
 
View through which the match scoring is done. Has buttons to log each 
possible outcome of a cricket delivery, and displays the scores of both
teams and the scores of the current batsmen and bowler. Has a button to go
to ScorecardView, presenting the whole match's scorecard, and another one
to go back to MatchesView. Makes use of DataController's updateMatchScore
method to update the score and save the changes to CoreData.
*/

import SwiftUI
import CoreData

struct ScoringView: View {
    @EnvironmentObject var sheetManager: SheetDismissalManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var match: FetchedResults<Match>.Element
    @FetchRequest(
        entity: Delivery.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Delivery.index, ascending: true)]
    ) var deliveries: FetchedResults<Delivery>
    @State var overthrow = false
    @State var undoNotPossible = false
    @State private var forceRefresh = false
    @State var outcome: Outcome = Outcome.dot
    @State var mostRecentDelivery: Int = 0
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(match.teamBattingFirst?.name ?? "Team 1") vs \(match.teamBowlingFirst?.name ?? "Team 2")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(EdgeInsets(top: 25, leading: 30, bottom: 0, trailing: 0))
                        Spacer()
                        Button(action: {dismiss()}){
                            Text("Back To Matches")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                        }
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 30))
                    }
                    HStack {
                        Text("Scoring Menu")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 175.0)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .cornerRadius(10)
                        NavigationLink(destination: ScorecardView(match: match)){
                            Text("Scorecard")
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .frame(width: 175)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                                )
                        }
                        .navigationBarBackButtonHidden(true)
                    }
                    .padding()
                    HStack {
                        Text("\(match.teamBattingFirst?.name ?? "Team 1")")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(match.teamBattingFirst?.runs ?? 0)/\(match.teamBattingFirst?.wicketsLost ?? 0)")
                            .font(.title3)
                            .fontWeight(.bold)
                        + Text(match.firstInningsFinished ? "  (\(Int(match.firstInningsDeliveriesBowledThatCount) / 6).\(Int(match.firstInningsDeliveriesBowledThatCount) % 6)/\(Int(match.totalDeliveries / 2) / 6).\(Int(match.totalDeliveries / 2) % 6) overs)" : "  (\(Int(match.deliveriesBowledThatCount) / 6).\(Int(match.deliveriesBowledThatCount) % 6)/\(Int(match.totalDeliveries / 2) / 6).\(Int(match.totalDeliveries / 2) % 6) overs)")
                            .font(.system(size: 10))
                    }
                    .padding(EdgeInsets(top: 10, leading: 30, bottom: 5, trailing: 30))
                    HStack {
                        Text("\(match.teamBowlingFirst?.name ?? "Team 2")")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        if (match.firstInningsFinished) {
                            Text("\(match.teamBowlingFirst?.runs ?? 0)/\(match.teamBowlingFirst?.wicketsLost ?? 0)")
                                .font(.title3)
                                .fontWeight(.bold)
                            + Text("  (\(Int(match.deliveriesBowledThatCount) / 6).\(Int(match.deliveriesBowledThatCount) % 6) overs)")
                                .font(.system(size: 10))
                        }
                    }
                    .padding(EdgeInsets(top: 5, leading: 30, bottom: 20, trailing: 30))
                    Grid {
                        GridRow {
                            Text("Batter")
                                .gridColumnAlignment(.leading)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                
                            Spacer()
                            Text("R")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 10))
                            Text("B")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 7.5))
                            Text("4")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 7.5))
                            Text("6")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 7.5))
                            Text("S/R")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 0))
                        }
                        .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                        GridRow {
                            HStack {
                                Text("\(match.striker?.name ?? "N/A")")
                                    .fontWeight(.semibold)
                                Text("*")
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Spacer()
                            Text("\(match.striker?.runs ?? -1)")
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(match.striker?.ballsFaced ?? -1)")
                                //.fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(match.striker?.fours ?? -1)")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(match.striker?.sixes ?? -1)")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(getStrikeRate(runs: match.striker?.runs ?? -1, ballsFaced: match.striker?.ballsFaced ?? -1))")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        }
                        GridRow {
                            Text("\(match.nonStriker?.name ?? "N/A")")
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                            Spacer()
                            Text("\(match.nonStriker?.runs ?? -1)")
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                            Text("\(match.nonStriker?.ballsFaced ?? -1)")
                                //.fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                            Text("\(match.nonStriker?.fours ?? -1)")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                            Text("\(match.nonStriker?.sixes ?? -1)")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                            Text("\(getStrikeRate(runs: match.nonStriker?.runs ?? -1, ballsFaced: match.nonStriker?.ballsFaced ?? -1))")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                        }
                    }
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    Grid {
                        GridRow {
                            Text("Bowler")
                                .gridColumnAlignment(.leading)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Spacer()
                            Text("O")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 10))
                            Text("W")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 7.5))
                            Text("R")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 7.5))
                            Text("E")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 7.5))
                            Text("E/R")
                                .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 10, trailing: 0))
                        }
                        .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                        GridRow {
                            Text("\(match.bowler?.name ?? "N/A")")
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Spacer()
                            Text("\(Int(match.bowler?.ballsBowled ?? -1) / 6).\(Int(match.bowler?.ballsBowled ?? -1) % 6)")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(match.bowler?.wickets ?? -1)")
                                .fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(match.bowler?.runsConceded ?? -1)")
                                //.fontWeight(.semibold)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(match.bowler?.extrasBowled ?? -1)")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            Text("\(getEconomy(ballsBowled: match.bowler?.ballsBowled ?? -1, runsConceded: match.bowler?.runsConceded ?? -1))")
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        }
                    }
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    HStack {
                        Text("This Over")
                            .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30))
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            HStack(spacing: 7.5) {
                                ForEach(deliveries) { delivery in
                                    if (delivery.specificMatch == match) {
                                        if (delivery.outcome == "0") {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 15/255, green: 115/255, blue: 15/255))
                                                    .frame(width: 45, height: 45)
                                                Text(".")
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                            }
                                            .onAppear {
                                                mostRecentDelivery = Int(getIdentifierForLastDelivery())
                                            }
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 15/255, green: 115/255, blue: 15/255))
                                                    .frame(width: 45, height: 45)
                                                Text("\(delivery.outcome ?? "")")
                                                    .font(.footnote)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            .onAppear {
                                                mostRecentDelivery = Int(getIdentifierForLastDelivery())
                                            }
                                        }
                                    }
                                }
                                .id(UUID())
                                .onChange(of: mostRecentDelivery) {
                                    proxy.scrollTo(Int64(mostRecentDelivery))
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25))
                    }
                    HStack (spacing: 10) {
                        Button(action: {
                            if (match.firstInningsFinished) {
                                if ((overthrow && (match.teamBowlingFirst?.runs ?? -1) + 4 > (match.teamBattingFirst?.runs ?? -1)) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.dot
                                    sheetManager.matchCompletedViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.dot
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.dot, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            } else {
                                if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.dot
                                    sheetManager.inningsSwitchViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.dot
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.dot, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("0")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: {
                            if (match.firstInningsFinished) {
                                if ((overthrow && (match.teamBowlingFirst?.runs ?? -1) + 5 > (match.teamBattingFirst?.runs ?? -1)) || (match.teamBowlingFirst?.runs ?? -1) + 1 > (match.teamBattingFirst?.runs ?? -1) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.one
                                    sheetManager.matchCompletedViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.one
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.one, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            } else {
                                if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.one
                                    sheetManager.inningsSwitchViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.one
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.one, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("1")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: {
                            if (match.firstInningsFinished) {
                                if ((overthrow && (match.teamBowlingFirst?.runs ?? -1) + 6 > (match.teamBattingFirst?.runs ?? -1)) || (match.teamBowlingFirst?.runs ?? -1) + 2 > (match.teamBattingFirst?.runs ?? -1) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.two
                                    sheetManager.matchCompletedViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.two
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.two, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            } else {
                                if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.two
                                    sheetManager.inningsSwitchViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.two
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.two, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("2")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: {
                            if (match.firstInningsFinished) {
                                if ((overthrow && (match.teamBowlingFirst?.runs ?? -1) + 7 > (match.teamBattingFirst?.runs ?? -1)) || (match.teamBowlingFirst?.runs ?? -1) + 3 > (match.teamBattingFirst?.runs ?? -1) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.three
                                    sheetManager.matchCompletedViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.three
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.three, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            } else {
                                if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.three
                                    sheetManager.inningsSwitchViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.three
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.three, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("3")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: {
                            if (match.firstInningsFinished) {
                                if ((overthrow && (match.teamBowlingFirst?.runs ?? -1) + 8 > (match.teamBattingFirst?.runs ?? -1)) || (match.teamBowlingFirst?.runs ?? -1) + 4 > (match.teamBattingFirst?.runs ?? -1) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.four
                                    sheetManager.matchCompletedViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.four
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.four, overthrow: overthrow, offTheBat: true, context: managedObjectContext)

                                }
                            } else {
                                if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.four
                                    sheetManager.inningsSwitchViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.four
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.four, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("4")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: {
                            if (match.firstInningsFinished) {
                                if ((match.teamBowlingFirst?.runs ?? -1) + 6 > (match.teamBattingFirst?.runs ?? -1) || match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.six
                                    sheetManager.matchCompletedViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.six
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.six, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            } else {
                                if (match.deliveriesBowledThatCount + 1 == (match.totalDeliveries)/2) {
                                    outcome = Outcome.six
                                    sheetManager.inningsSwitchViewShowing = true
                                } else if (match.deliveriesBowledThatCount % 6 == 5) {
                                    outcome = Outcome.six
                                    sheetManager.nextBowlerViewShowing = true
                                } else {
                                    DataController.shared.updateMatchScore(match: match, outcome: Outcome.six, overthrow: overthrow, offTheBat: true, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("6")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 25, bottom: 15, trailing: 25))
                    HStack (spacing: 10) {
                        Button(action: {sheetManager.wicketsViewShowing = true}) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Text("W")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action: {sheetManager.widesViewShowing = true}) {
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                                    .frame(width: 55, height: 55)
                                Text("wd")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            }
                        }
                        Button(action: {sheetManager.noBallViewShowing = true}) {
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                                    .frame(width: 55, height: 55)
                                Text("nb")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            }
                        }
                        Button(action: {sheetManager.byesViewShowing = true}) {
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                                    .frame(width: 55, height: 55)
                                Text("b")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            }
                        }
                        Button(action: {sheetManager.legByesViewShowing = true}) {
                            ZStack {
                                Circle()
                                    .fill(Color.clear)
                                    .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                                    .frame(width: 55, height: 55)
                                Text("lb")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            }
                        }
                        Button(action: {
                            if (match.deliveriesBowled == 0) {
                                undoNotPossible = true
                            } else {
                                let deliveries: NSSet = match.inningsTracker ?? NSSet()
                                let sortedDeliveries = deliveries.filter { $0 is Delivery }.map { $0 as! Delivery }.sorted(by: { $0.index < $1.index })
                                let mostRecentDelivery = sortedDeliveries.last!
                                if (mostRecentDelivery.outcome == "W") {
                                    undoNotPossible = true
                                } else {
                                    DataController.shared.undoLastDelivery(match: match, context: managedObjectContext)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                    .frame(width: 55, height: 55)
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .alert("Error", isPresented: $undoNotPossible) {
                            Button("OK", role: .cancel) {
                                undoNotPossible = false
                            }
                        } message: {
                            if (match.deliveriesBowled == 0) {
                                Text("Undo not possible: no deliveries have been bowled yet.")
                            } else {
                                Text("Undo not possible: the last delivery was a wicket, or in the previous over.")
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                    HStack {
                        Toggle("Add 4 Runs", isOn: $overthrow)
                                        .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255)))
                                        .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 30, bottom: 0, trailing: 30))
                }
                .navigationBarHidden(true)
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $sheetManager.wicketsViewShowing) {
            WicketView(match: match)
        }
        .sheet(isPresented: $sheetManager.widesViewShowing) {
            WidesView(overthrow: $overthrow, match: match)
        }
        .sheet(isPresented: $sheetManager.noBallViewShowing) {
            NoBallView(overthrow: $overthrow, match: match)
        }
        .sheet(isPresented: $sheetManager.byesViewShowing) {
            ByesView(overthrow: $overthrow, match: match)
        }
        .sheet(isPresented: $sheetManager.legByesViewShowing) {
            LegByesView(overthrow: $overthrow, match: match)
        }
        .sheet(isPresented: $sheetManager.nextBowlerViewShowing) {
            NextBowlerView(outcome: $outcome, overthrow: overthrow, offTheBat: true, match: match)
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $sheetManager.inningsSwitchViewShowing) {
            InningsSwitchView(outcome: $outcome, overthrow: overthrow, offTheBat: true, match: match)
                .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $sheetManager.matchCompletedViewShowing) {
            MatchCompletedView(outcome: $outcome, overthrow: overthrow, offTheBat: true, match: match)
                .interactiveDismissDisabled(true)
        }
        .onChange(of: match) {
            forceRefresh.toggle()
        }
    }
    
    private func getStrikeRate(runs: Int64, ballsFaced: Int64) -> String {
        if (ballsFaced == 0) {
            let roundedStrikeRate = round(Double(ballsFaced) * 10) / 10
            return String(format: "%.1f", roundedStrikeRate)
        }
        let unroundedStrikeRate =  Double(Double(runs)/Double(ballsFaced)) * 100
        let roundedStrikeRate = (round(unroundedStrikeRate * 10) / 10)
        return String(format: "%.1f", roundedStrikeRate)
    }
    
    private func getEconomy(ballsBowled: Int64, runsConceded: Int64) -> String {
        if (ballsBowled == 0) {
            let roundedEconomy = round(Double(ballsBowled) * 10) / 10
            return String(format: "%.2f", roundedEconomy)
        }
        let oversBowled: Double = Double(Double(ballsBowled) / 6)
        let unroundedEconomy = Double(runsConceded) / oversBowled
        let roundedEconomy = round(unroundedEconomy * 100) / 100
        return String(format: "%.2f", roundedEconomy)
    }
    
    private func getIdentifierForLastDelivery() -> Int64 {
        let deliveries = NSOrderedSet(set: (match.inningsTracker ?? NSSet()) as! Set<AnyHashable>).sorted { ($0 as! Delivery).index < ($1 as! Delivery).index } as! [Delivery]
        return deliveries.last?.index ?? 0
    }
    
}

/*
#Preview {
    ScoringView()
}
*/
