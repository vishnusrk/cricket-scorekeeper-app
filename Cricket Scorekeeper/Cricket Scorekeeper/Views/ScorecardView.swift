/*
Vishnu Sreekanth

Cricket Scorekeeper

ScorecardView.swift
 
Displays a full scorecard of the match. Accessed through ScoringView,
or directly through MatchesView if the specific match that was tapped is
over.
*/

import SwiftUI
import CoreData

struct ScorecardView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var match: FetchedResults<Match>.Element
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("\(match.teamBattingFirst?.name ?? "Team 1") vs \(match.teamBowlingFirst?.name ?? "Team 2")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 15, bottom: 0, trailing: 0))
                    Spacer()
                    if (match.completed) {
                        Button(action: {dismiss()}){
                            Text("Back To Matches")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                        }
                        .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 15))
                    }
                }
                if (match.completed) {
                    Text("\(match.result ?? "N/A")")
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 0))
                } else {
                    HStack {
                        Button(action:{dismiss()}) {
                            Text("Scoring Menu")
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .frame(width: 175.0)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255), lineWidth: 2)
                                )
                                .cornerRadius(10)
                        }
                        Text("Scorecard")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 175)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .cornerRadius(10)
                    }
                    .padding()
                }
                HStack {
                    Text("\(match.teamBattingFirst?.name ?? "Team 1")")
                        .font(.title3)
                        .fontWeight(.bold)
                        //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                    Spacer()
                    Text("\(match.teamBattingFirst?.runs ?? 0)/\(match.teamBattingFirst?.wicketsLost ?? 0)")
                        .font(.title3)
                        .fontWeight(.bold)
                        //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                    + Text(match.firstInningsFinished ? "  (\(Int(match.firstInningsDeliveriesBowledThatCount) / 6).\(Int(match.firstInningsDeliveriesBowledThatCount) % 6)/\(Int(match.totalDeliveries / 2) / 6).\(Int(match.totalDeliveries / 2) % 6) overs)" : "  (\(Int(match.deliveriesBowledThatCount) / 6).\(Int(match.deliveriesBowledThatCount) % 6)/\(Int(match.totalDeliveries / 2) / 6).\(Int(match.totalDeliveries / 2) % 6) overs)")
                        .font(.system(size: 10))
                        //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                HStack {
                    Text("\(match.teamBowlingFirst?.name ?? "Team 2")")
                        .font(.title3)
                        .fontWeight(.bold)
                        //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                    Spacer()
                    if (match.firstInningsFinished) {
                        Text("\(match.teamBowlingFirst?.runs ?? 0)/\(match.teamBowlingFirst?.wicketsLost ?? 0)")
                            .font(.title3)
                            .fontWeight(.bold)
                            //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                        + Text("  (\(Int(match.deliveriesBowledThatCount) / 6).\(Int(match.deliveriesBowledThatCount) % 6)/\(Int(match.totalDeliveries / 2) / 6).\(Int(match.totalDeliveries / 2) % 6) overs)")
                            .font(.system(size: 10))
                            //.foregroundColor(Color(red: 89/255, green: 206/255, blue: 89/255))
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 20, trailing: 15))
                if (match.firstInningsFinished && !match.completed) {
                    Text("\(match.teamBowlingFirst?.name ?? "N/A") need \((match.teamBattingFirst?.runs ?? -1) - (match.teamBowlingFirst?.runs ?? -1) + 1) runs from \((match.totalDeliveries/2) - match.deliveriesBowledThatCount) balls")
                        .font(.subheadline)
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 20, trailing: 15))
                }
                HStack {
                    Text("\(match.teamBattingFirst?.name ?? "Team 1")")
                        .font(.headline)
                        .fontWeight(.bold)
                    + Text(match.firstInningsFinished ? "  (\(Int(match.firstInningsDeliveriesBowledThatCount) / 6).\(Int(match.firstInningsDeliveriesBowledThatCount) % 6) overs)" : "  (\(Int(match.deliveriesBowledThatCount) / 6).\(Int(match.deliveriesBowledThatCount) % 6) overs)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
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
                    ForEach(NSOrderedSet(set: (match.teamBattingFirst?.players ?? NSSet()) as! Set<AnyHashable>).sorted {($0 as! Player).battingPosition < ($1 as! Player).battingPosition } as! [Player], id: \.self) { player in
                        if (player.battingPosition != 0) {
                            GridRow {
                                Text("\(player.name ?? "N/A")")
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                Spacer()
                                Text("\(player.runs)")
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                Text("\(player.ballsFaced)")
                                    //.fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                Text("\(player.fours)")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                Text("\(player.sixes)")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                Text("\(getStrikeRate(runs: player.runs, ballsFaced: player.ballsFaced))")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2.5, trailing: 0))
                            }
                            GridRow {
                                Text("\(player.outDescription ?? "N/A")")
                                    .font(.system(size: 10))
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                Spacer()
                            }
                        }
                    }
                }
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                HStack {
                    Text("Extras")
                    Spacer()
                    Text("\(match.teamBattingFirst?.extras ?? -1)")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                }
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                
                HStack {
                    Text("Total")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(match.teamBattingFirst?.runs ?? -1)/\(match.teamBattingFirst?.wicketsLost ?? -1)")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 15))
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
                    ForEach(NSOrderedSet(set: (match.teamBowlingFirst?.players ?? NSSet()) as! Set<AnyHashable>).sorted {($0 as! Player).bowlingPosition < ($1 as! Player).bowlingPosition } as! [Player], id: \.self) { player in
                        if (player.bowlingPosition != 0) {
                            GridRow {
                                Text("\(player.name ?? "N/A")")
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                Spacer()
                                Text("\(Int(player.ballsBowled) / 6).\(Int(player.ballsBowled) % 6)")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                Text("\(player.wickets)")
                                    .fontWeight(.semibold)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                Text("\(player.runsConceded)")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                Text("\(player.extrasBowled)")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                Text("\(getEconomy(ballsBowled: player.ballsBowled, runsConceded: player.runsConceded))")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            }
                        }
                    }  
                }
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 35, trailing: 15))
                if (match.firstInningsFinished) {
                    HStack {
                        Text("\(match.teamBowlingFirst?.name ?? "Team 2")")
                            .font(.headline)
                            .fontWeight(.bold)
                        + Text("  (\(Int(match.deliveriesBowledThatCount) / 6).\(Int(match.deliveriesBowledThatCount) % 6) overs)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
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
                        ForEach(NSOrderedSet(set: (match.teamBowlingFirst?.players ?? NSSet()) as! Set<AnyHashable>).sorted {($0 as! Player).battingPosition < ($1 as! Player).battingPosition } as! [Player], id: \.self) { player in
                            if (player.battingPosition != 0) {
                                GridRow {
                                    Text("\(player.name ?? "N/A")")
                                        .fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                    Spacer()
                                    Text("\(player.runs)")
                                        .fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                    Text("\(player.ballsFaced)")
                                        //.fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                    Text("\(player.fours)")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                    Text("\(player.sixes)")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                    Text("\(getStrikeRate(runs: player.runs, ballsFaced: player.ballsFaced))")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0))
                                }
                                GridRow {
                                    Text("\(player.outDescription ?? "N/A")")
                                        .font(.system(size: 10))
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    Spacer()
                                }
                            }
                        }
                    }
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                    HStack {
                        Text("Extras")
                        Spacer()
                        Text("\(match.teamBowlingFirst?.extras ?? -1)")
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                    HStack {
                        Text("Total")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(match.teamBowlingFirst?.runs ?? -1)/\(match.teamBowlingFirst?.wicketsLost ?? -1)")
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 15))
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
                        ForEach(NSOrderedSet(set: (match.teamBattingFirst?.players ?? NSSet()) as! Set<AnyHashable>).sorted {($0 as! Player).bowlingPosition < ($1 as! Player).bowlingPosition } as! [Player], id: \.self) { player in
                            if (player.bowlingPosition != 0) {
                                GridRow {
                                    Text("\(player.name ?? "N/A")")
                                        .fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    Spacer()
                                    Text("\(Int(player.ballsBowled) / 6).\(Int(player.ballsBowled) % 6)")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    Text("\(player.wickets)")
                                        .fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    Text("\(player.runsConceded)")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    Text("\(player.extrasBowled)")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    Text("\(getEconomy(ballsBowled: player.ballsBowled, runsConceded: player.runsConceded))")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                }
                            }
                        }
                    }
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
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
    
}

/*
 #Preview {
 ScorecardView()
 }
*/
