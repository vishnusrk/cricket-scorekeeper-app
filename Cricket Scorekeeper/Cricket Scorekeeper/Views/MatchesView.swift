/*
Vishnu Sreekanth

Cricket Scorekeeper

MatchesView.swift
 
Displays all of the matches that have been created using a CoreData fetch
request in a list. Has a + button to create a match that goes to
MatchCreationView. Also has a home button that goes back to MainView.
When a match is tapped on in the list, it goes to StartMatchView, ScoringView,
or ScorecardView for that match by passing the match to the view. The view
it goes to depends on the match's state.
*/

import SwiftUI
import CoreData

struct MatchesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)]) var match: FetchedResults<Match>
    @State private var showingDeleteAlert = false
    @State private var matchToDelete: Match?
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Matches")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                    Spacer()
                    Button(action: {dismiss()}){
                        Image(systemName: "house.fill")
                            .font(.system(size: 30))
                            .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                    }
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 5))
                    NavigationLink(destination: MatchCreationView()){
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                    }
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 25))
                }
                Spacer()
                List {
                    ForEach(match) { match in
                        let teamsArray = match.teams?.compactMap { $0 as? Team } ?? []
                        VStack {
                            Text(match.started ? "\(match.teamBattingFirst?.name ?? "N/A") vs \(match.teamBowlingFirst?.name ?? "N/A")" : "\(teamsArray.dropFirst().first?.name ?? "N/A") vs \(teamsArray.first?.name ?? "N/A")")
                                .fontWeight(.bold)
                                .padding(EdgeInsets(top: 30, leading: 25, bottom: 5, trailing: 25))
                                .multilineTextAlignment(.center)
                            Text("\(match.overs) Over Match")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                            Spacer()
                            HStack {
                                Spacer()
                                NavigationLink(destination: match.completed ? AnyView(ScorecardView(match: match)) : (match.started ? AnyView(ScoringView(match: match)) : AnyView(StartMatchView(match: match)))) {
                                }
                            }
                            Spacer()
                            Text("\(match.startDate ?? Date())")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                            Spacer()
                            Text(match.completed ? "\(match.result ?? "Completed")" : (match.started ? "In Progress" : "Not Yet Started"))
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(EdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 25))
                            Spacer()
                        }
                        .swipeActions(content: {
                            Button(action: {
                                matchToDelete = match
                                showingDeleteAlert = true
                            }, label: {
                                Image(systemName: "trash")
                            })
                            .tint(Color.red)
                        })
                    }
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Match"),
                        message: Text("Are you sure you want to delete this match?"),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteMatch(match: matchToDelete ?? Match())
                        },
                        secondaryButton: .cancel()
                    )
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    private func deleteMatch(match: Match) {
        withAnimation {
            managedObjectContext.delete(match)
            DataController.shared.save(context: managedObjectContext)
        }
    }
    
}

#Preview {
    MatchesView()
}
