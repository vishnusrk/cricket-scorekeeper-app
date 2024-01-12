/*
Vishnu Sreekanth

Cricket Scorekeeper

StartMatchView.swift
 
Accessed through MatchesView when a match that has just been created 
and not started yet is tapped. Asks for information needed to start the
match (which team is batting first, who is on strike, who is opening the
bowling), and calls DataController.swift's startMatch method to start the
match and save it to CoreData when Confirm is tapped. Immediately redirects
to the match's ScoringView after this.
*/

import SwiftUI
import CoreData

struct StartMatchView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State var battingTeam = ""
    @State var bowlingTeam = ""
    @State var striker = ""
    @State var strikerId: UUID? = nil
    @State var nonStriker = ""
    @State var nonStrikerId: UUID? = nil
    @State var bowler = ""
    @State var bowlerId: UUID? = nil
    @State var teamSelected = false
    @State var allFieldsNotFilled = false
    @State var matchStarted = false
    var match: FetchedResults<Match>.Element
    var body: some View {
        let teamsArray = match.teams?.compactMap { $0 as? Team } ?? []
        let teamOneArray = teamsArray.first?.players?.compactMap { $0 as? Player } ?? []
        let teamTwoArray = teamsArray.dropFirst().first?.players?.compactMap { $0 as? Player } ?? []
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Start Match")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 0))
                        Spacer()
                    }
                    VStack {
                        Text("Batting Team")
                        Menu {
                            Button(
                                action: {
                                    if (battingTeam != teamsArray.first?.name) {
                                        battingTeam = teamsArray.first?.name ?? "N/A"
                                        bowlingTeam = teamsArray.dropFirst().first?.name ?? "N/A"
                                        teamSelected = true
                                        striker = ""
                                        nonStriker = ""
                                        bowler = ""
                                        strikerId = nil
                                        nonStrikerId = nil
                                        bowlerId = nil
                                    }
                                },
                                label: {Text("\(teamsArray.first?.name ?? "N/A")")}
                            )
                            Button(
                                action: {
                                    if (battingTeam != teamsArray.dropFirst().first?.name ?? "N/A") {
                                        battingTeam = teamsArray.dropFirst().first?.name ?? "N/A"
                                        bowlingTeam = teamsArray.first?.name ?? "N/A"
                                        teamSelected = true
                                        striker = ""
                                        nonStriker = ""
                                        bowler = ""
                                        strikerId = nil
                                        nonStrikerId = nil
                                        bowlerId = nil
                                    }
                                },
                                label: {Text("\(teamsArray.dropFirst().first?.name ?? "N/A")")}
                            )
                        } label: {
                            Label (
                                title: {
                                    Text("\(battingTeam)")
                                        .foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                                        .fontWeight(.bold)
                                },
                                icon: {Image(systemName: "plus").foregroundColor(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))}
                            )
                        }
                        
                    }
                    .padding()
                    if (teamSelected) {
                        VStack {
                            Text("Striker (\(battingTeam))")
                                .multilineTextAlignment(.center)
                            if (battingTeam == teamsArray.first?.name) {
                                Menu {
                                    ForEach(teamOneArray) { player in
                                        if let unwrappedUUID = nonStrikerId {
                                            if (unwrappedUUID != player.id) {
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
                            } else {
                                Menu {
                                    ForEach(teamTwoArray) { player in
                                        if let unwrappedUUID = nonStrikerId {
                                            if (unwrappedUUID != player.id) {
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
                        }
                        .padding()
                        VStack {
                            Text("Non Striker (\(battingTeam))")
                                .multilineTextAlignment(.center)
                            if (battingTeam == teamsArray.first?.name) {
                                Menu {
                                    ForEach(teamOneArray) { player in
                                        if let unwrappedUUID = strikerId {
                                            if (unwrappedUUID != player.id) {
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
                            } else {
                                Menu {
                                    ForEach(teamTwoArray) { player in
                                        if let unwrappedUUID = strikerId {
                                            if (unwrappedUUID != player.id) {
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
                        }
                        .padding()
                        VStack {
                            Text("Opening Bowler (\(bowlingTeam))")
                                .multilineTextAlignment(.center)
                            if (battingTeam == teamsArray.first?.name) {
                                Menu {
                                    ForEach(teamTwoArray) { player in
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
                            } else {
                                Menu {
                                    ForEach(teamOneArray) { player in
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
                        }
                        .padding()
                    }
                    HStack {
                        Button("Start Match") {
                            if (battingTeam.isEmpty || bowlingTeam.isEmpty || striker.isEmpty || nonStriker.isEmpty || bowler.isEmpty) {
                                allFieldsNotFilled = true
                            } else {
                                DataController.shared.startMatch(match: match, battingTeam: battingTeam, striker: strikerId, nonStriker: nonStrikerId, bowler: bowlerId, context: managedObjectContext)
                                matchStarted = true
                            }
                        }
                        .alert("Error", isPresented: $allFieldsNotFilled) {
                            Button("OK", role: .cancel) {
                                allFieldsNotFilled = false
                            }
                        } message: {
                            Text("Please fill all of the fields.")
                        }
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .frame(width: 175)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .background(colorScheme == .dark ? Color(red: 89/255, green: 206/255, blue: 89/255) : Color(red: 85/255, green: 185/255, blue: 85/255))
                            .cornerRadius(10)
                        Button(action: {dismiss()}){
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
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .navigationDestination(isPresented: $matchStarted) {
                ScoringView(match: match).environment(\.managedObjectContext, managedObjectContext)
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .onAppear {
            if (match.started) {
                dismiss()
            }
        }
        
    }
}

/*
 #Preview {
 GetMatchReadyView()
 }
*/
