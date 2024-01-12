/*
Vishnu Sreekanth

Cricket Scorekeeper

DataController.swift
 
Class responsible for making changes to matches and saving them to 
CoreData. Has methods to create a match, start it, update it, undo
its last delivery, switch its innings, and complete it. Due to the
nuances in how cricket scores work, the update match method is 
particularly long, with many cases to account for. Saves all changes
made to CoreData using the save method. Works in conjunction with 
the DataModel xcdatamodel file outlining the Match, Team, Player,
and Delivery entities that are used to keep track of the score.
*/

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "DataModel")
    
    static var shared = DataController()
    
    init() {
        container.loadPersistentStores {desc, error in
            if let error = error {
                print("Yo there's an error: \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Error: data could not be saved")
        }
    }
    
    func createMatch(overs: Int64, teamSize: Int64, teamOneName: String, teamTwoName: String, teamOnePlayerNames: [String], teamTwoPlayerNames: [String], context: NSManagedObjectContext) {
        let match = Match(context: context)
        match.id = UUID()
        match.startDate = Date()
        match.started = false
        match.firstInningsFinished = false
        match.completed = false
        match.deliveriesBowled = 0
        match.deliveriesBowledThatCount = 0
        match.overs = overs
        match.totalDeliveries = overs * 12
        match.teamSize = teamSize
        match.firstInningsDeliveriesBowledThatCount = 0
        match.inningsTracker = NSSet()
        match.bowlerHasNotStartedOver = true
        match.numDifferentBowlers = 0
        match.result = ""
        let teamOne = Team(context: context)
        teamOne.name = teamOneName
        teamOne.runs = 0
        teamOne.extras = 0
        teamOne.wicketsLost = 0
        var teamOnePlayerArray = [Player]()
        for playerName in teamOnePlayerNames {
            if (playerName != "") {
                let player = Player(context: context)
                player.id = UUID()
                player.name = playerName
                player.runs = 0
                player.wickets = 0
                player.runsConceded = 0
                player.ballsFaced = 0
                player.ballsBowled = 0
                player.fours = 0
                player.sixes = 0
                player.extrasBowled = 0
                player.battingPosition = 0
                player.bowlingPosition = 0
                player.outDescription = "not out"
                teamOnePlayerArray.append(player)
            }
        }
        teamOne.players = NSSet(array: teamOnePlayerArray)
        let teamTwo = Team(context: context)
        teamTwo.name = teamTwoName
        teamTwo.runs = 0
        teamTwo.extras = 0
        teamTwo.wicketsLost = 0
        var teamTwoPlayerArray = [Player]()
        for playerName in teamTwoPlayerNames {
            if (playerName != "") {
                let player = Player(context: context)
                player.id = UUID()
                player.name = playerName
                player.runs = 0
                player.wickets = 0
                player.runsConceded = 0
                player.ballsFaced = 0
                player.ballsBowled = 0
                player.fours = 0
                player.sixes = 0
                player.extrasBowled = 0
                player.battingPosition = 0
                player.bowlingPosition = 0
                player.outDescription = "not out"
                teamTwoPlayerArray.append(player)
            }
        }
        teamTwo.players = NSSet(array: teamTwoPlayerArray)
        let teams = [teamOne, teamTwo]
        match.teams = NSSet(array: teams)
        save(context: context)
        print("createMatch: Context saved!")
    }
    
    func startMatch(match: Match, battingTeam: String, striker: UUID?, nonStriker: UUID?, bowler: UUID?, context: NSManagedObjectContext) {
        let teamsArray = match.teams?.compactMap { $0 as? Team } ?? []
        for team in teamsArray {
            if (team.name == battingTeam) {
                match.teamBattingFirst = team;
            } else {
                match.teamBowlingFirst = team;
            }
        }
        match.currentBattingTeam = match.teamBattingFirst
        match.currentBowlingTeam = match.teamBowlingFirst
        let battingTeamArray = match.teamBattingFirst?.players?.compactMap { $0 as? Player } ?? []
        let bowlingTeamArray = match.teamBowlingFirst?.players?.compactMap { $0 as? Player } ?? []
        for player in battingTeamArray {
            if (striker == player.id) {
                match.striker = player
                player.battingPosition = 1
            }
            if (nonStriker == player.id) {
                match.nonStriker = player
                player.battingPosition = 2
            }
        }
        for player in bowlingTeamArray {
            if (bowler == player.id) {
                match.bowler = player
                player.bowlingPosition = 1
                match.numDifferentBowlers = 1
            }
        }
        match.started = true
        save(context: context)
        print("startMatch: Context saved!")
    }
    

    func updateMatchScore(match: Match, outcome: Outcome, secondaryOutcome: Int? = 0, outString: String? = "", overthrow: Bool = false, offTheBat: Bool, wicketWasWide: Bool = false, playerThatGotOut: UUID? = nil, newBatter: UUID? = nil, crossedOver: Bool = false,  fielderResponsible: UUID? = nil, newBowler: UUID? = nil, context: NSManagedObjectContext) {
        switch outcome {
        case Outcome.dot:
            if (overthrow) {
                match.currentBattingTeam?.runs += 4
                match.striker?.runs += 4
                match.bowler?.runsConceded += 4
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "0+4"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            } else {
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "0"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            }
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.deliveriesBowled += 1
            match.deliveriesBowledThatCount += 1
        case Outcome.one:
            if (overthrow) {
                match.currentBattingTeam?.runs += 5
                match.striker?.runs += 5
                match.bowler?.runsConceded += 5
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "1+4"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            } else {
                match.currentBattingTeam?.runs += 1
                match.striker?.runs += 1
                match.bowler?.runsConceded += 1
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "1"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            }
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.deliveriesBowled += 1
            match.deliveriesBowledThatCount += 1
            let temp = match.striker
            match.striker = match.nonStriker
            match.nonStriker = temp
        case Outcome.two:
            if (overthrow) {
                match.currentBattingTeam?.runs += 6
                match.striker?.runs += 6
                match.bowler?.runsConceded += 6
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "2+4"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            } else {
                match.currentBattingTeam?.runs += 2
                match.striker?.runs += 2
                match.bowler?.runsConceded += 2
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "2"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            }
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.deliveriesBowled += 1
            match.deliveriesBowledThatCount += 1
        case Outcome.three:
            if (overthrow) {
                match.currentBattingTeam?.runs += 7
                match.striker?.runs += 7
                match.bowler?.runsConceded += 7
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "3+4"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            } else {
                match.currentBattingTeam?.runs += 3
                match.striker?.runs += 3
                match.bowler?.runsConceded += 3
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "3"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            }
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.deliveriesBowled += 1
            match.deliveriesBowledThatCount += 1
            let temp = match.striker
            match.striker = match.nonStriker
            match.nonStriker = temp
        case Outcome.four:
            if (overthrow) {
                match.currentBattingTeam?.runs += 8
                match.striker?.runs += 8
                match.bowler?.runsConceded += 8
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "4+4"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            } else {
                match.currentBattingTeam?.runs += 4
                match.striker?.runs += 4
                match.bowler?.runsConceded += 4
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "4"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
            }
            match.striker?.ballsFaced += 1
            match.striker?.fours += 1
            match.bowler?.ballsBowled += 1
            match.deliveriesBowled += 1
            match.deliveriesBowledThatCount += 1
        case Outcome.six:
            match.currentBattingTeam?.runs += 6
            match.striker?.runs += 6
            match.bowler?.runsConceded += 6
            match.striker?.ballsFaced += 1
            match.striker?.sixes += 1
            match.bowler?.ballsBowled += 1
            let delivery = Delivery(context: context)
            delivery.index = match.deliveriesBowled
            delivery.outcome = "6"
            let innings = match.inningsTracker
            let mutableCopy = innings?.mutableCopy() as! NSMutableSet
            mutableCopy.add(delivery)
            match.inningsTracker = mutableCopy
            match.deliveriesBowled += 1
            match.deliveriesBowledThatCount += 1
        case Outcome.wide:
            switch secondaryOutcome {
            case 0:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 5
                    match.currentBattingTeam?.extras += 5
                    match.bowler?.extrasBowled += 5
                    match.bowler?.runsConceded += 5
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "0wd+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                } else {
                    match.currentBattingTeam?.runs += 1
                    match.currentBattingTeam?.extras += 1
                    match.bowler?.extrasBowled += 1
                    match.bowler?.runsConceded += 1
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "0wd"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                }
            case 1:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 6
                    match.currentBattingTeam?.extras += 6
                    match.bowler?.extrasBowled += 6
                    match.bowler?.runsConceded += 6
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "1wd+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                } else {
                    match.currentBattingTeam?.runs += 2
                    match.currentBattingTeam?.extras += 2
                    match.bowler?.extrasBowled += 2
                    match.bowler?.runsConceded += 2
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "1wd"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                }
            case 2:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 7
                    match.currentBattingTeam?.extras += 7
                    match.bowler?.extrasBowled += 7
                    match.bowler?.runsConceded += 7
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "2wd+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                } else {
                    match.currentBattingTeam?.runs += 3
                    match.currentBattingTeam?.extras += 3
                    match.bowler?.extrasBowled += 3
                    match.bowler?.runsConceded += 3
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "2wd"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                }
            case 3:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 8
                    match.currentBattingTeam?.extras += 8
                    match.bowler?.extrasBowled += 8
                    match.bowler?.runsConceded += 8
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "3wd+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                } else {
                    match.currentBattingTeam?.runs += 4
                    match.currentBattingTeam?.extras += 4
                    match.bowler?.extrasBowled += 4
                    match.bowler?.runsConceded += 4
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "3wd"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                }
            case 4:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 9
                    match.currentBattingTeam?.extras += 9
                    match.bowler?.extrasBowled += 9
                    match.bowler?.runsConceded += 9
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "4wd+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                } else {
                    match.currentBattingTeam?.runs += 5
                    match.currentBattingTeam?.extras += 5
                    match.bowler?.extrasBowled += 5
                    match.bowler?.runsConceded += 5
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "4wd"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                }
            default:
                print("")
            }
        case Outcome.noBall:
            if (offTheBat) {
                switch secondaryOutcome {
                case 0:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 5
                        match.currentBattingTeam?.extras += 5
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 5
                        match.bowler?.runsConceded += 5
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "0nb+4"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 1
                        match.currentBattingTeam?.extras += 1
                        match.bowler?.extrasBowled += 1
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "0nb"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    }
                case 1:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 6
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 5
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 6
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "1nb+4"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    } else {
                        match.currentBattingTeam?.runs += 2
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 1
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 2
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "1nb"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    }
                case 2:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 7
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 6
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 7
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "2nb+4"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 3
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 2
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 3
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "2nb"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    }
                case 3:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 8
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 7
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 8
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "3nb+4"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    } else {
                        match.currentBattingTeam?.runs += 4
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 3
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 4
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "3nb"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    }
                case 4:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 9
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 8
                        match.striker?.fours += 1
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 9
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "4nb+4"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 5
                        match.currentBattingTeam?.extras += 1
                        match.striker?.runs += 4
                        match.striker?.fours += 1
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 5
                        match.bowler?.extrasBowled += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "4nb"
                        delivery.additionalInfo = "*"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    }
                case 6:
                    match.currentBattingTeam?.runs += 7
                    match.currentBattingTeam?.extras += 1
                    match.striker?.runs += 6
                    match.striker?.sixes += 1
                    match.striker?.ballsFaced += 1
                    match.bowler?.runsConceded += 7
                    match.bowler?.extrasBowled += 1
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "6nb"
                    delivery.additionalInfo = "*"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                    match.deliveriesBowled += 1
                default:
                    print("")
                }
            } else {
                switch secondaryOutcome {
                case 0:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 5
                        match.currentBattingTeam?.extras += 5
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 5
                        match.bowler?.runsConceded += 5
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "0nb+4"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 1
                        match.currentBattingTeam?.extras += 1
                        match.bowler?.extrasBowled += 1
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 1
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "0nb"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    }
                case 1:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 6
                        match.currentBattingTeam?.extras += 6
                        match.bowler?.extrasBowled += 6
                        match.striker?.ballsFaced += 1
                        match.bowler?.runsConceded += 6
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "1nb+4"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    } else {
                        match.currentBattingTeam?.runs += 2
                        match.currentBattingTeam?.extras += 2
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 2
                        match.bowler?.runsConceded += 2
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "1nb"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    }
                case 2:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 7
                        match.currentBattingTeam?.extras += 7
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 7
                        match.bowler?.runsConceded += 7
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "2nb+4"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 3
                        match.currentBattingTeam?.extras += 3
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 3
                        match.bowler?.runsConceded += 3
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "2nb"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    }
                case 3:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 8
                        match.currentBattingTeam?.extras += 8
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 8
                        match.bowler?.runsConceded += 8
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "3nb+4"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    } else {
                        match.currentBattingTeam?.runs += 4
                        match.currentBattingTeam?.extras += 4
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 4
                        match.bowler?.runsConceded += 4
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "3nb"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                        let temp = match.striker
                        match.striker = match.nonStriker
                        match.nonStriker = temp
                    }
                case 4:
                    if (overthrow) {
                        match.currentBattingTeam?.runs += 9
                        match.currentBattingTeam?.extras += 9
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 9
                        match.bowler?.runsConceded += 9
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "4nb+4"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 5
                        match.currentBattingTeam?.extras += 5
                        match.striker?.ballsFaced += 1
                        match.bowler?.extrasBowled += 5
                        match.bowler?.runsConceded += 5
                        let delivery = Delivery(context: context)
                        delivery.index = match.deliveriesBowled
                        delivery.outcome = "4nb"
                        let innings = match.inningsTracker
                        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                        mutableCopy.add(delivery)
                        match.inningsTracker = mutableCopy
                        match.deliveriesBowled += 1
                    }
                default:
                    print("")
                }
            }
        case Outcome.bye:
            switch secondaryOutcome {
            case 1:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 5
                    match.currentBattingTeam?.extras += 5
                    match.bowler?.extrasBowled += 5
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "1b+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 1
                    match.currentBattingTeam?.extras += 1
                    match.bowler?.extrasBowled += 1
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "1b"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
                let temp = match.striker
                match.striker = match.nonStriker
                match.nonStriker = temp
            case 2:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 6
                    match.currentBattingTeam?.extras += 6
                    match.bowler?.extrasBowled += 6
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "2b+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 2
                    match.currentBattingTeam?.extras += 2
                    match.bowler?.extrasBowled += 2
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "2b"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
            case 3:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 7
                    match.currentBattingTeam?.extras += 7
                    match.bowler?.extrasBowled += 7
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "3b+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 3
                    match.currentBattingTeam?.extras += 3
                    match.bowler?.extrasBowled += 3
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "3b"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
                let temp = match.striker
                match.striker = match.nonStriker
                match.nonStriker = temp
            case 4:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 8
                    match.currentBattingTeam?.extras += 8
                    match.bowler?.extrasBowled += 8
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "4b+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 4
                    match.currentBattingTeam?.extras += 4
                    match.bowler?.extrasBowled += 4
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "4b"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
            default:
                print("")
            }
        case Outcome.legBye:
            switch secondaryOutcome {
            case 1:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 5
                    match.currentBattingTeam?.extras += 5
                    match.bowler?.extrasBowled += 5
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "1lb+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 1
                    match.currentBattingTeam?.extras += 1
                    match.bowler?.extrasBowled += 1
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "1lb"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
                let temp = match.striker
                match.striker = match.nonStriker
                match.nonStriker = temp
            case 2:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 6
                    match.currentBattingTeam?.extras += 6
                    match.bowler?.extrasBowled += 6
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "2lb+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 2
                    match.currentBattingTeam?.extras += 2
                    match.bowler?.extrasBowled += 2
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "2lb"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
            case 3:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 7
                    match.currentBattingTeam?.extras += 7
                    match.bowler?.extrasBowled += 7
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "3lb+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 3
                    match.currentBattingTeam?.extras += 3
                    match.bowler?.extrasBowled += 3
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "3lb"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
                let temp = match.striker
                match.striker = match.nonStriker
                match.nonStriker = temp
            case 4:
                if (overthrow) {
                    match.currentBattingTeam?.runs += 8
                    match.currentBattingTeam?.extras += 8
                    match.bowler?.extrasBowled += 8
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "4lb+4"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                } else {
                    match.currentBattingTeam?.runs += 4
                    match.currentBattingTeam?.extras += 4
                    match.bowler?.extrasBowled += 4
                    let delivery = Delivery(context: context)
                    delivery.index = match.deliveriesBowled
                    delivery.outcome = "4lb"
                    let innings = match.inningsTracker
                    let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                    mutableCopy.add(delivery)
                    match.inningsTracker = mutableCopy
                }
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.deliveriesBowled += 1
                match.deliveriesBowledThatCount += 1
            default:
                print("")
            }
        case Outcome.wicket:
            let battingTeam = match.currentBattingTeam?.players?.compactMap { $0 as? Player } ?? []
            let bowlingTeam = match.currentBowlingTeam?.players?.compactMap { $0 as? Player } ?? []
            switch outString {
            case "Run Out":
                if (wicketWasWide) {
                    if (offTheBat) {
                        match.currentBattingTeam?.runs += 1 + Int64(secondaryOutcome ?? 0)
                        match.striker?.runs += Int64(secondaryOutcome ?? 0)
                        match.currentBattingTeam?.extras += 1
                        match.bowler?.runsConceded += 1 + Int64(secondaryOutcome ?? 0)
                        match.bowler?.extrasBowled += 1
                    } else {
                        match.currentBattingTeam?.runs += 1 + Int64(secondaryOutcome ?? 0)
                        match.currentBattingTeam?.extras += 1 + Int64(secondaryOutcome ?? 0)
                        match.bowler?.runsConceded += 1 + Int64(secondaryOutcome ?? 0)
                        match.bowler?.extrasBowled += 1 + Int64(secondaryOutcome ?? 0)
                    }
                    if (crossedOver) {
                        if ((secondaryOutcome ?? 0) % 2 == 0) {
                            let temp = match.striker
                            match.striker = match.nonStriker
                            match.nonStriker = temp
                        }
                    } else {
                        if ((secondaryOutcome ?? 0) % 2 != 0) {
                            let temp = match.striker
                            match.striker = match.nonStriker
                            match.nonStriker = temp
                        }
                    }
                } else {
                    if (offTheBat) {
                        match.striker?.runs += Int64(secondaryOutcome ?? 0)
                        match.bowler?.runsConceded += Int64(secondaryOutcome ?? 0)
                    } else {
                        match.currentBattingTeam?.extras += Int64(secondaryOutcome ?? 0)
                        match.bowler?.extrasBowled += Int64(secondaryOutcome ?? 0)
                    }
                    match.currentBattingTeam?.runs += Int64(secondaryOutcome ?? 0)
                    match.striker?.ballsFaced += 1
                    match.bowler?.ballsBowled += 1
                    match.deliveriesBowledThatCount += 1
                    if (crossedOver) {
                        if ((secondaryOutcome ?? 0) % 2 == 0) {
                            let temp = match.striker
                            match.striker = match.nonStriker
                            match.nonStriker = temp
                        }
                    } else {
                        if ((secondaryOutcome ?? 0) % 2 != 0) {
                            let temp = match.striker
                            match.striker = match.nonStriker
                            match.nonStriker = temp
                        }
                    }
                }
                match.currentBattingTeam?.wicketsLost += 1
                var nextBatter: Player?
                var fielderName: String = ""
                for player in battingTeam {
                    if (newBatter == player.id) {
                        nextBatter = player
                    }
                }
                for player in bowlingTeam {
                    if (fielderResponsible == player.id) {
                        fielderName = player.name ?? ""
                    }
                }
                nextBatter?.battingPosition = (match.currentBattingTeam?.wicketsLost ?? 0) + 2
                if (playerThatGotOut == match.striker?.id) {
                    match.striker?.outDescription = "run out (\(fielderName))"
                    match.striker = nextBatter
                } else {
                    match.nonStriker?.outDescription = "run out (\(fielderName))"
                    match.nonStriker = nextBatter
                }
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "W"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled += 1
            case "Hit Wicket":
                if (wicketWasWide) {
                    match.currentBattingTeam?.runs += 1
                    match.currentBattingTeam?.extras += 1
                    match.bowler?.extrasBowled += 1
                    match.bowler?.runsConceded += 1
                } else {
                    match.striker?.ballsFaced += 1
                    match.bowler?.ballsBowled += 1
                    match.deliveriesBowledThatCount += 1
                }
                match.bowler?.wickets += 1
                match.currentBattingTeam?.wicketsLost += 1
                var nextBatter: Player?
                for player in battingTeam {
                    if (newBatter == player.id) {
                        nextBatter = player
                    }
                }
                nextBatter?.battingPosition = (match.currentBattingTeam?.wicketsLost ?? 0) + 2
                match.striker?.outDescription = "hit wicket b \(match.bowler?.name ?? "N/A")"
                match.striker = nextBatter
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "W"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled += 1
            case "Stumped":
                if (wicketWasWide) {
                    match.currentBattingTeam?.runs += 1
                    match.currentBattingTeam?.extras += 1
                    match.bowler?.extrasBowled += 1
                    match.bowler?.runsConceded += 1
                } else {
                    match.striker?.ballsFaced += 1
                    match.bowler?.ballsBowled += 1
                    match.deliveriesBowledThatCount += 1
                }
                match.bowler?.wickets += 1
                match.currentBattingTeam?.wicketsLost += 1
                var nextBatter: Player?
                var fielderName: String = ""
                for player in battingTeam {
                    if (newBatter == player.id) {
                        nextBatter = player
                    }
                }
                for player in bowlingTeam {
                    if (fielderResponsible == player.id) {
                        fielderName = player.name ?? ""
                    }
                }
                nextBatter?.battingPosition = (match.currentBattingTeam?.wicketsLost ?? 0) + 2
                match.striker?.outDescription = "st \(fielderName) b \(match.bowler?.name ?? "N/A")"
                match.striker = nextBatter
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "W"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled += 1
            case "Caught":
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.bowler?.wickets += 1
                match.currentBattingTeam?.wicketsLost += 1
                match.deliveriesBowledThatCount += 1
                var nextBatter: Player?
                var fielderName: String = ""
                for player in battingTeam {
                    if (newBatter == player.id) {
                        nextBatter = player
                    }
                }
                for player in bowlingTeam {
                    if (fielderResponsible == player.id) {
                        fielderName = player.name ?? ""
                    }
                }
                nextBatter?.battingPosition = (match.currentBattingTeam?.wicketsLost ?? 0) + 2
                match.striker?.outDescription = "c \(fielderName) b \(match.bowler?.name ?? "N/A")"
                match.striker = nextBatter
                if (crossedOver) {
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                }
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "W"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled += 1
            case "Bowled":
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.bowler?.wickets += 1
                match.currentBattingTeam?.wicketsLost += 1
                match.deliveriesBowledThatCount += 1
                var nextBatter: Player?
                for player in battingTeam {
                    if (newBatter == player.id) {
                        nextBatter = player
                    }
                }
                nextBatter?.battingPosition = (match.currentBattingTeam?.wicketsLost ?? 0) + 2
                match.striker?.outDescription = "b \(match.bowler?.name ?? "N/A")"
                match.striker = nextBatter
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "W"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled += 1
            case "LBW":
                match.striker?.ballsFaced += 1
                match.bowler?.ballsBowled += 1
                match.bowler?.wickets += 1
                match.currentBattingTeam?.wicketsLost += 1
                match.deliveriesBowledThatCount += 1
                var nextBatter: Player?
                for player in battingTeam {
                    if (newBatter == player.id) {
                        nextBatter = player
                    }
                }
                nextBatter?.battingPosition = (match.currentBattingTeam?.wicketsLost ?? 0) + 2
                match.striker?.outDescription = "lbw b \(match.bowler?.name ?? "N/A")"
                match.striker = nextBatter
                let delivery = Delivery(context: context)
                delivery.index = match.deliveriesBowled
                delivery.outcome = "W"
                let innings = match.inningsTracker
                let mutableCopy = innings?.mutableCopy() as! NSMutableSet
                mutableCopy.add(delivery)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled += 1
            default:
                print("")
            }
        }
        save(context: context)
        if (match.deliveriesBowledThatCount % 6 == 0 && match.deliveriesBowledThatCount != 0 && !match.bowlerHasNotStartedOver)  {
            let temp = match.striker
            match.striker = match.nonStriker
            match.nonStriker = temp
            for delivery in match.inningsTracker ?? [] {
                context.delete(delivery as! NSManagedObject)
            }
            let innings = match.inningsTracker
            let mutableCopy = innings?.mutableCopy() as! NSMutableSet
            mutableCopy.removeAllObjects()
            match.inningsTracker = mutableCopy
            match.deliveriesBowled = 0
            var nextBowler: Player?
            let bowlingTeam = match.currentBowlingTeam?.players?.compactMap { $0 as? Player } ?? []
            for player in bowlingTeam {
                if (newBowler == player.id) {
                    nextBowler = player
                }
            }
            if (nextBowler?.ballsBowled == 0) {
                nextBowler?.bowlingPosition = match.numDifferentBowlers + 1
                match.numDifferentBowlers += 1
            }
            match.bowlerHasNotStartedOver = true
            match.bowler = nextBowler
            save(context: context)
            print("updateMatchScore: Context saved!")
        } else {
            if (!wicketWasWide && outcome != Outcome.wide && outcome != Outcome.noBall) {
                match.bowlerHasNotStartedOver = false
            }
            save(context: context)
            print("updateMatchScore: Context saved!")
        }
    }
    
    func undoLastDelivery(match: Match, context: NSManagedObjectContext) {
        if (match.deliveriesBowled != 0) {
            let deliveries: NSSet? = match.inningsTracker
            let sortedDeliveries = deliveries?.filter { $0 is Delivery }.map { $0 as! Delivery }.sorted(by: { $0.index < $1.index })
            let mostRecentDelivery = sortedDeliveries?.last!
            if (mostRecentDelivery?.outcome != "W") {
                switch mostRecentDelivery?.outcome {
                case "0":
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "1":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 1
                    match.striker?.runs -= 1
                    match.striker?.ballsFaced -= 1
                    match.bowler?.runsConceded -= 1
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "2":
                    match.currentBattingTeam?.runs -= 2
                    match.striker?.runs -= 2
                    match.striker?.ballsFaced -= 1
                    match.bowler?.runsConceded -= 2
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "3":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 3
                    match.striker?.runs -= 3
                    match.striker?.ballsFaced -= 1
                    match.bowler?.runsConceded -= 3
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "4":
                    match.currentBattingTeam?.runs -= 4
                    match.striker?.runs -= 4
                    match.striker?.fours -= 1
                    match.striker?.ballsFaced -= 1
                    match.bowler?.runsConceded -= 4
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "6":
                    match.currentBattingTeam?.runs -= 6
                    match.striker?.runs -= 6
                    match.striker?.sixes -= 1
                    match.striker?.ballsFaced -= 1
                    match.bowler?.runsConceded -= 6
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "0wd":
                    match.currentBattingTeam?.runs -= 1
                    match.currentBattingTeam?.extras -= 1
                    match.bowler?.runsConceded -= 1
                    match.bowler?.extrasBowled -= 1
                case "0wd+4":
                    match.currentBattingTeam?.runs -= 5
                    match.currentBattingTeam?.extras -= 5
                    match.bowler?.runsConceded -= 5
                    match.bowler?.extrasBowled -= 5
                case "1wd":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 2
                    match.currentBattingTeam?.extras -= 2
                    match.bowler?.runsConceded -= 2
                    match.bowler?.extrasBowled -= 2
                case "1wd+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 6
                    match.currentBattingTeam?.extras -= 6
                    match.bowler?.runsConceded -= 6
                    match.bowler?.extrasBowled -= 6
                case "2wd":
                    match.currentBattingTeam?.runs -= 3
                    match.currentBattingTeam?.extras -= 3
                    match.bowler?.runsConceded -= 3
                    match.bowler?.extrasBowled -= 3
                case "2wd+4":
                    match.currentBattingTeam?.runs -= 7
                    match.currentBattingTeam?.extras -= 7
                    match.bowler?.runsConceded -= 7
                    match.bowler?.extrasBowled -= 7
                case "3wd":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 4
                    match.currentBattingTeam?.extras -= 4
                    match.bowler?.runsConceded -= 4
                    match.bowler?.extrasBowled -= 4
                case "3wd+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 8
                    match.currentBattingTeam?.extras -= 8
                    match.bowler?.runsConceded -= 8
                    match.bowler?.extrasBowled -= 8
                case "4wd":
                    match.currentBattingTeam?.runs -= 5
                    match.currentBattingTeam?.extras -= 5
                    match.bowler?.runsConceded -= 5
                    match.bowler?.extrasBowled -= 5
                case "4wd+4":
                    match.currentBattingTeam?.runs -= 9
                    match.currentBattingTeam?.extras -= 9
                    match.bowler?.runsConceded -= 9
                    match.bowler?.extrasBowled -= 9
                case "0nb":
                    match.currentBattingTeam?.runs -= 1
                    match.currentBattingTeam?.extras -= 1
                    match.bowler?.runsConceded -= 1
                    match.bowler?.extrasBowled -= 1
                case "0nb+4":
                    match.currentBattingTeam?.runs -= 5
                    match.currentBattingTeam?.extras -= 5
                    match.bowler?.runsConceded -= 5
                    match.bowler?.extrasBowled -= 5
                case "1nb":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 2
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 1
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 2
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 2
                        match.bowler?.runsConceded -= 2
                        match.bowler?.extrasBowled -= 2
                    }
                case "1nb+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 6
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 5
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 6
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 6
                        match.bowler?.runsConceded -= 6
                        match.bowler?.extrasBowled -= 6
                    }
                case "2nb":
                    match.currentBattingTeam?.runs -= 3
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 2
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 3
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 3
                        match.bowler?.runsConceded -= 3
                        match.bowler?.extrasBowled -= 3
                    }
                case "2nb+4":
                    match.currentBattingTeam?.runs -= 7
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 6
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 7
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 7
                        match.bowler?.runsConceded -= 7
                        match.bowler?.extrasBowled -= 7
                    }
                case "3nb": 
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 4
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 3
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 4
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 4
                        match.bowler?.runsConceded -= 4
                        match.bowler?.extrasBowled -= 4
                    }
                case "3nb+4": 
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 8
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 7
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 8
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 8
                        match.bowler?.runsConceded -= 8
                        match.bowler?.extrasBowled -= 8
                    }
                case "4nb": 
                    match.currentBattingTeam?.runs -= 5
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 4
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 5
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 5
                        match.bowler?.runsConceded -= 5
                        match.bowler?.extrasBowled -= 5
                    }
                case "4nb+4": 
                    match.currentBattingTeam?.runs -= 9
                    if (mostRecentDelivery?.additionalInfo == "*") {
                        match.striker?.runs -= 8
                        match.currentBattingTeam?.extras -= 1
                        match.bowler?.runsConceded -= 9
                        match.bowler?.extrasBowled -= 1
                    } else {
                        match.currentBattingTeam?.extras -= 9
                        match.bowler?.runsConceded -= 9
                        match.bowler?.extrasBowled -= 9
                    }
                case "6nb":
                    match.currentBattingTeam?.runs -= 7
                    match.striker?.runs -= 6
                    match.currentBattingTeam?.extras -= 1
                    match.bowler?.runsConceded -= 7
                    match.bowler?.extrasBowled -= 1
                case "1b":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 1
                    match.currentBattingTeam?.extras -= 1
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "1b+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 5
                    match.currentBattingTeam?.extras -= 5
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 5
                    match.deliveriesBowledThatCount -= 1
                case "2b": 
                    match.currentBattingTeam?.runs -= 2
                    match.currentBattingTeam?.extras -= 2
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 2
                    match.deliveriesBowledThatCount -= 1
                case "2b+4":
                    match.currentBattingTeam?.runs -= 6
                    match.currentBattingTeam?.extras -= 6
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 6
                    match.deliveriesBowledThatCount -= 1
                case "3b": 
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 3
                    match.currentBattingTeam?.extras -= 3
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 3
                    match.deliveriesBowledThatCount -= 1
                case "3b+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 7
                    match.currentBattingTeam?.extras -= 7
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 7
                    match.deliveriesBowledThatCount -= 1
                case "4b":  
                    match.currentBattingTeam?.runs -= 4
                    match.currentBattingTeam?.extras -= 4
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 4
                    match.deliveriesBowledThatCount -= 1
                case "4b+4": 
                    match.currentBattingTeam?.runs -= 8
                    match.currentBattingTeam?.extras -= 8
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 8
                    match.deliveriesBowledThatCount -= 1
                case "1lb":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 1
                    match.currentBattingTeam?.extras -= 1
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                case "1lb+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 5
                    match.currentBattingTeam?.extras -= 5
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 5
                    match.deliveriesBowledThatCount -= 1
                case "2lb":
                    match.currentBattingTeam?.runs -= 2
                    match.currentBattingTeam?.extras -= 2
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 2
                    match.deliveriesBowledThatCount -= 1
                case "2lb+4":
                    match.currentBattingTeam?.runs -= 6
                    match.currentBattingTeam?.extras -= 6
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 6
                    match.deliveriesBowledThatCount -= 1
                case "3lb":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 3
                    match.currentBattingTeam?.extras -= 3
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 3
                    match.deliveriesBowledThatCount -= 1
                case "3lb+4":
                    let temp = match.striker
                    match.striker = match.nonStriker
                    match.nonStriker = temp
                    match.currentBattingTeam?.runs -= 7
                    match.currentBattingTeam?.extras -= 7
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 7
                    match.deliveriesBowledThatCount -= 1
                case "4lb":
                    match.currentBattingTeam?.runs -= 4
                    match.currentBattingTeam?.extras -= 4
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 4
                    match.deliveriesBowledThatCount -= 1
                case "4lb+4":
                    match.currentBattingTeam?.runs -= 8
                    match.currentBattingTeam?.extras -= 8
                    match.striker?.ballsFaced -= 1
                    match.bowler?.ballsBowled -= 1
                    match.bowler?.extrasBowled -= 8
                    match.deliveriesBowledThatCount -= 1
                default:
                    print("")
                }
                let mutableCopy = deliveries as! NSMutableSet
                mutableCopy.remove(mostRecentDelivery!)
                context.delete(mostRecentDelivery!)
                match.inningsTracker = mutableCopy
                match.deliveriesBowled -= 1
            }
            save(context: context)
            print("undoLastDelivery: Context saved!")
        } else {
            print("Undo won't work cause no deliveries have been bowled")
        }
    }
    
    func switchInnings(match: Match, striker: UUID?, nonStriker: UUID?, bowler: UUID?, context: NSManagedObjectContext) {
        let temp = match.currentBattingTeam
        match.currentBattingTeam = match.currentBowlingTeam
        match.currentBowlingTeam = temp
        let battingTeamArray = match.currentBattingTeam?.players?.compactMap { $0 as? Player } ?? []
        let bowlingTeamArray = match.currentBowlingTeam?.players?.compactMap { $0 as? Player } ?? []
        for player in battingTeamArray {
            if (striker == player.id) {
                match.striker = player
                player.battingPosition = 1
            }
            if (nonStriker == player.id) {
                match.nonStriker = player
                player.battingPosition = 2
            }
        }
        for player in bowlingTeamArray {
            if (bowler == player.id) {
                match.bowler = player
                player.bowlingPosition = 1
            }
        }
        match.numDifferentBowlers = 0
        match.firstInningsDeliveriesBowledThatCount = match.deliveriesBowledThatCount
        match.deliveriesBowledThatCount = 0
        match.deliveriesBowled = 0
        match.bowlerHasNotStartedOver = true
        match.firstInningsFinished = true
        for delivery in match.inningsTracker ?? [] {
            context.delete(delivery as! NSManagedObject)
        }
        let innings = match.inningsTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.removeAllObjects()
        match.inningsTracker = mutableCopy
        save(context: context)
        print("switchInnings: Context saved!")
    }
    
    func completeMatch(match: Match, context: NSManagedObjectContext) {
        for delivery in match.inningsTracker ?? [] {
            context.delete(delivery as! NSManagedObject)
        }
        let innings = match.inningsTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.removeAllObjects()
        match.inningsTracker = mutableCopy
        if ((match.teamBattingFirst?.runs ?? -1) > (match.teamBowlingFirst?.runs ?? -1)) {
            if ((match.teamBattingFirst?.runs ?? -1) - (match.teamBowlingFirst?.runs ?? -1) == 1) {
                match.result = "\(match.teamBattingFirst?.name ?? "N/A") won by \((match.teamBattingFirst?.runs ?? -1) - (match.teamBowlingFirst?.runs ?? -1)) run!"
            } else {
                match.result = "\(match.teamBattingFirst?.name ?? "N/A") won by \((match.teamBattingFirst?.runs ?? -1) - (match.teamBowlingFirst?.runs ?? -1)) runs!"
            }
        } else if ((match.teamBowlingFirst?.runs ?? -1) > (match.teamBattingFirst?.runs ?? -1)) {
            if (match.teamSize - 1 - (match.teamBowlingFirst?.wicketsLost ?? -1) == 1) {
                match.result = "\(match.teamBowlingFirst?.name ?? "N/A") won by \(match.teamSize - 1 - (match.teamBowlingFirst?.wicketsLost ?? -1)) wicket!"
            } else {
                match.result = "\(match.teamBowlingFirst?.name ?? "N/A") won by \(match.teamSize - 1 - (match.teamBowlingFirst?.wicketsLost ?? -1)) wickets!"
            }
        } else {
            match.result = "Match tied!"
        }
        match.completed = true
        save(context: context)
        print("completeMatch: Context saved!")
    }
    
}
