/*
Vishnu Sreekanth

Cricket Scorekeeper

DataController.swift
 
Class responsible for making changes to matches and saving them to 
CoreData. Has methods to create a match, start it, update it, undo
its last delivery, switch its innings, and complete it. Saves all
changes made to CoreData using the save method. Works in conjunction
with the DataModel xcdatamodel file outlining the Match, Team, Player,
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
                print("Error: \(error.localizedDescription)")
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
        match.overTracker = NSSet()
        match.bowlerHasNotStartedOver = true
        match.numDifferentBowlers = 0
        match.battersSentIn = 0
        match.result = ""
        let teamOne = Team(context: context)
        _initTeam(team: teamOne, teamName: teamOneName, playerNames: teamOnePlayerNames, context: context)
        let teamTwo = Team(context: context)
        _initTeam(team: teamTwo, teamName: teamTwoName, playerNames: teamTwoPlayerNames, context: context)
        let teams = [teamOne, teamTwo]
        match.teams = NSSet(array: teams)
        save(context: context)
        print("createMatch: Context saved!")
    }
    
    func startMatch(match: Match, battingTeam: String, striker: UUID?, nonStriker: UUID?, bowler: UUID?, context: NSManagedObjectContext) {
        for team in match.teams ?? NSSet() {
            if ((team as AnyObject).name == battingTeam) {
                match.teamBattingFirst = team as? Team;
            } else {
                match.teamBowlingFirst = team as? Team;
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
        match.battersSentIn = 2
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
    
    func updateMatchScore(match: Match, outcome: Outcome, secondaryOutcome: Int? = 0, outString: String? = "", offTheBat: Bool, wicketWasWide: Bool = false, playerThatGotOut: UUID? = nil, newBatter: UUID? = nil, crossedOver: Bool = false,  fielderResponsible: UUID? = nil, newBowler: UUID? = nil, context: NSManagedObjectContext) {
        switch outcome {
        case Outcome.dot:
            _incrementMatchScoreWithNonExtras(runsToAdd: 0, match: match, context: context)
        case Outcome.one:
            _incrementMatchScoreWithNonExtras(runsToAdd: 1, match: match, context: context)
        case Outcome.two:
            _incrementMatchScoreWithNonExtras(runsToAdd: 2, match: match, context: context)
        case Outcome.three:
            _incrementMatchScoreWithNonExtras(runsToAdd: 3, match: match, context: context)
        case Outcome.four:
            _incrementMatchScoreWithNonExtras(runsToAdd: 4, match: match, context: context)
        case Outcome.five:
            _incrementMatchScoreWithNonExtras(runsToAdd: 5, match: match, context: context)
        case Outcome.six:
            _incrementMatchScoreWithNonExtras(runsToAdd: 6, match: match, context: context)
        case Outcome.seven:
            _incrementMatchScoreWithNonExtras(runsToAdd: 7, match: match, context: context)
        case Outcome.eight:
            _incrementMatchScoreWithNonExtras(runsToAdd: 8, match: match, context: context)
        case Outcome.wide:
            _incrementMatchScoreWithWide(runsToAdd: (secondaryOutcome ?? -1), match: match, context: context)
        case Outcome.noBall:
            _incrementMatchScoreWithNoBall(runsToAdd: (secondaryOutcome ?? -1), batterHitBall: offTheBat, match: match, context: context)
        case Outcome.bye:
            _incrementMatchScoreWithBye(runsToAdd: (secondaryOutcome ?? -1), isLegBye: false, match: match, context: context)
        case Outcome.legBye:
            _incrementMatchScoreWithBye(runsToAdd: (secondaryOutcome ?? -1), isLegBye: true, match: match, context: context)
        case Outcome.wicket:
            _dismissBatter(secondaryOutcome: secondaryOutcome, outString: outString, batterHitBall: offTheBat, wicketWasWide: wicketWasWide, playerThatGotOut: playerThatGotOut, newBatter: newBatter, crossedOver: crossedOver, fielderResponsible: fielderResponsible, match: match, context: context)
        }
        save(context: context)
        /*
        End of over mechanics follow.
        */
        if (match.deliveriesBowledThatCount % 6 == 0 && match.deliveriesBowledThatCount != 0 && !match.bowlerHasNotStartedOver)  {
            _switchStrikerAndNonStriker(match: match, context: context)
            for delivery in match.overTracker ?? [] {
                context.delete(delivery as! NSManagedObject)
            }
            let innings = match.overTracker
            let mutableCopy = innings?.mutableCopy() as! NSMutableSet
            mutableCopy.removeAllObjects()
            match.overTracker = mutableCopy
            match.deliveriesBowled = 0
            var nextBowler: Player?
            for player in match.currentBowlingTeam?.players ?? NSSet() {
                if (newBowler == (player as AnyObject).id) {
                    nextBowler = player as? Player
                }
            }
            if (nextBowler?.ballsBowled == 0) {
                nextBowler?.bowlingPosition = match.numDifferentBowlers + 2
                match.numDifferentBowlers += 1
            }
            match.bowlerHasNotStartedOver = true
            match.bowler = nextBowler
        } else {
            if (!wicketWasWide && outcome != Outcome.wide && outcome != Outcome.noBall) {
                match.bowlerHasNotStartedOver = false
            }
        }
        save(context: context)
        print("updateMatchScore: Context saved!")
    }
    
    func undoLastDelivery(match: Match, context: NSManagedObjectContext) {
        if (match.deliveriesBowled != 0) {
            let deliveries: NSSet? = match.overTracker
            let sortedDeliveries = deliveries?.filter { $0 is Delivery }.map { $0 as! Delivery }.sorted(by: { $0.index < $1.index })
            let mostRecentDelivery = sortedDeliveries?.last!
            if (mostRecentDelivery?.outcome != "W") {
                let deliveryString = mostRecentDelivery?.outcome ?? ""
                if (deliveryString.contains("wd") || deliveryString.contains("b")) {
                    if (deliveryString.contains("nb")) {
                        let numRuns = (Int64(deliveryString.replacingOccurrences(of: "nb", with: "")) ?? 0)
                        if (numRuns % 2 == 1) {
                            _switchStrikerAndNonStriker(match: match, context: context)
                        }
                        match.currentBattingTeam?.runs -= (1 + numRuns)
                        match.bowler?.runsConceded -= (1 + numRuns)
                        match.striker?.ballsFaced -= 1
                        if (mostRecentDelivery?.additionalInfo == "*") {
                            match.striker?.runs -= numRuns
                            match.currentBattingTeam?.extras -= 1
                            match.bowler?.extrasBowled -= 1
                            if (numRuns == 4) {
                                match.striker?.fours -= 1
                            } else if (numRuns == 6) {
                                match.striker?.sixes -= 1
                            }
                        } else {
                            match.currentBattingTeam?.extras -= (1 + numRuns)
                            match.bowler?.extrasBowled -= (1 + numRuns)
                        }
                    } else if (deliveryString.contains("b")) {
                        var numRuns: Int64 = 0
                        if (deliveryString.contains("lb")) {
                            numRuns = (Int64(deliveryString.replacingOccurrences(of: "lb", with: "")) ?? 0)
                        } else {
                            numRuns = (Int64(deliveryString.replacingOccurrences(of: "b", with: "")) ?? 0)
                        }
                        if (numRuns % 2 == 1) {
                            _switchStrikerAndNonStriker(match: match, context: context)
                        }
                        match.currentBattingTeam?.runs -= numRuns
                        match.currentBattingTeam?.extras -= numRuns
                        match.bowler?.extrasBowled -= numRuns
                        match.bowler?.ballsBowled -= 1
                        match.striker?.ballsFaced -= 1
                        match.deliveriesBowledThatCount -= 1
                    } else {
                        let numRuns = (Int64(deliveryString.replacingOccurrences(of: "wd", with: "")) ?? 0)
                        if (numRuns % 2 == 1) {
                            _switchStrikerAndNonStriker(match: match, context: context)
                        }
                        match.currentBattingTeam?.runs -= (1 + numRuns)
                        match.currentBattingTeam?.extras -= (1 + numRuns)
                        match.bowler?.runsConceded -= (1 + numRuns)
                        match.bowler?.extrasBowled -= (1 + numRuns)
                    }
                } else {
                    if ((Int64(deliveryString) ?? 0) % 2 == 1) {
                        _switchStrikerAndNonStriker(match: match, context: context)
                    }
                    match.currentBattingTeam?.runs -= Int64(deliveryString) ?? 0
                    match.striker?.runs -= Int64(deliveryString) ?? 0
                    match.striker?.ballsFaced -= 1
                    match.bowler?.runsConceded -= Int64(deliveryString) ?? 0
                    match.bowler?.ballsBowled -= 1
                    match.deliveriesBowledThatCount -= 1
                    if ((Int64(deliveryString) ?? 0) == 4) {
                        match.striker?.fours -= 1
                    } else if ((Int64(deliveryString) ?? 0) == 6) {
                        match.striker?.sixes -= 1
                    }
                }
                let mutableCopy = deliveries as! NSMutableSet
                mutableCopy.remove(mostRecentDelivery!)
                context.delete(mostRecentDelivery!)
                match.overTracker = mutableCopy
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
        match.battersSentIn = 2
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
        for delivery in match.overTracker ?? [] {
            context.delete(delivery as! NSManagedObject)
        }
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.removeAllObjects()
        match.overTracker = mutableCopy
        save(context: context)
        print("switchInnings: Context saved!")
    }
    
    func completeMatch(match: Match, context: NSManagedObjectContext) {
        for delivery in match.overTracker ?? [] {
            context.delete(delivery as! NSManagedObject)
        }
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.removeAllObjects()
        match.overTracker = mutableCopy
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
    
    private func _initTeam(team: Team, teamName: String, playerNames: [String], context: NSManagedObjectContext) {
        team.name = teamName
        team.runs = 0
        team.extras = 0
        team.wicketsLost = 0
        var playerArray = [Player]()
        for playerName in playerNames {
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
                playerArray.append(player)
            }
        }
        team.players = NSSet(array: playerArray)
        save(context: context)
    }
    
    private func _incrementMatchScoreWithNonExtras(runsToAdd: Int, match: Match, context: NSManagedObjectContext) {
        match.currentBattingTeam?.runs += Int64(runsToAdd)
        match.striker?.runs += Int64(runsToAdd)
        match.bowler?.runsConceded += Int64(runsToAdd)
        let delivery = Delivery(context: context)
        delivery.index = match.deliveriesBowled
        delivery.outcome = String(runsToAdd)
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.add(delivery)
        match.overTracker = mutableCopy
        match.striker?.ballsFaced += 1
        match.bowler?.ballsBowled += 1
        match.deliveriesBowled += 1
        match.deliveriesBowledThatCount += 1
        if (runsToAdd == 4) {
            match.striker?.fours += 1
        } else if (runsToAdd == 6) {
            match.striker?.sixes += 1
        }
        save(context: context)
        if (runsToAdd % 2 == 1) {
           _switchStrikerAndNonStriker(match: match, context: context)
        }
    }
    
    private func _incrementMatchScoreWithWide(runsToAdd: Int, match: Match, context: NSManagedObjectContext) {
        match.currentBattingTeam?.runs += Int64(1 + runsToAdd)
        match.currentBattingTeam?.extras += Int64(1 + runsToAdd)
        match.bowler?.runsConceded += Int64(1 + runsToAdd)
        match.bowler?.extrasBowled += Int64(1 + runsToAdd)
        let delivery = Delivery(context: context)
        delivery.index = match.deliveriesBowled
        delivery.outcome = String(runsToAdd) + "wd"
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.add(delivery)
        match.overTracker = mutableCopy
        match.deliveriesBowled += 1
        save(context: context)
        if (runsToAdd % 2 == 1) {
           _switchStrikerAndNonStriker(match: match, context: context)
        }
    }
    
    private func _incrementMatchScoreWithNoBall(runsToAdd: Int, batterHitBall: Bool, match: Match, context: NSManagedObjectContext) {
        match.currentBattingTeam?.runs += Int64(1 + runsToAdd)
        match.striker?.ballsFaced += 1
        match.bowler?.runsConceded += Int64(1 + runsToAdd)
        let delivery = Delivery(context: context)
        delivery.index = match.deliveriesBowled
        delivery.outcome = String(runsToAdd) + "nb"
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.add(delivery)
        match.overTracker = mutableCopy
        match.deliveriesBowled += 1
        if (batterHitBall) {
            delivery.additionalInfo = "*"
            match.currentBattingTeam?.extras += 1
            match.striker?.runs += Int64(runsToAdd)
            match.bowler?.extrasBowled += 1
            if (runsToAdd == 4) {
                match.striker?.fours += 1
            } else if (runsToAdd == 6) {
                match.striker?.sixes += 1
            }
        } else {
            match.currentBattingTeam?.extras += Int64(1 + runsToAdd)
            match.bowler?.extrasBowled += Int64(1 + runsToAdd)
        }
        save(context: context)
        if (runsToAdd % 2 == 1) {
           _switchStrikerAndNonStriker(match: match, context: context)
        }
    }
    
    private func _incrementMatchScoreWithBye(runsToAdd: Int, isLegBye: Bool, match: Match, context: NSManagedObjectContext) {
        match.currentBattingTeam?.runs += Int64(runsToAdd)
        match.currentBattingTeam?.extras += Int64(runsToAdd)
        match.bowler?.extrasBowled += Int64(runsToAdd)
        let delivery = Delivery(context: context)
        delivery.index = match.deliveriesBowled
        if (isLegBye) {
            delivery.outcome = String(runsToAdd) + "lb"
        } else {
            delivery.outcome = String(runsToAdd) + "b"
        }
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.add(delivery)
        match.overTracker = mutableCopy
        match.striker?.ballsFaced += 1
        match.bowler?.ballsBowled += 1
        match.deliveriesBowled += 1
        match.deliveriesBowledThatCount += 1
        save(context: context)
        if (runsToAdd % 2 == 1) {
           _switchStrikerAndNonStriker(match: match, context: context)
        }
    }
    
    private func _dismissBatter(secondaryOutcome: Int?, outString: String?, batterHitBall: Bool, wicketWasWide: Bool = false, playerThatGotOut: UUID?, newBatter: UUID?, crossedOver: Bool = false, fielderResponsible: UUID?, match: Match, context: NSManagedObjectContext) {
        var nextBatter: Player?
        var fielderName: String = ""
        switch outString {
        case "Run Out":
            if (wicketWasWide) {
                if (batterHitBall) {
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
                save(context: context)
                if (crossedOver) {
                    if ((secondaryOutcome ?? 0) % 2 == 0) {
                        _switchStrikerAndNonStriker(match: match, context: context)
                    }
                } else {
                    if ((secondaryOutcome ?? 0) % 2 != 0) {
                        _switchStrikerAndNonStriker(match: match, context: context)
                    }
                }
            } else {
                if (batterHitBall) {
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
                save(context: context)
                if (crossedOver) {
                    if ((secondaryOutcome ?? 0) % 2 == 0) {
                        _switchStrikerAndNonStriker(match: match, context: context)
                    }
                } else {
                    if ((secondaryOutcome ?? 0) % 2 != 0) {
                        _switchStrikerAndNonStriker(match: match, context: context)
                    }
                }
            }
            match.currentBattingTeam?.wicketsLost += 1
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            for player in match.currentBowlingTeam?.players ?? NSSet() {
                if (fielderResponsible == (player as AnyObject).id) {
                    fielderName = (player as AnyObject).name ?? ""
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            if (playerThatGotOut == match.striker?.id) {
                match.striker?.outDescription = "run out (\(fielderName))"
                match.striker = nextBatter
            } else {
                match.nonStriker?.outDescription = "run out (\(fielderName))"
                match.nonStriker = nextBatter
            }
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
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "hit wicket b \(match.bowler?.name ?? "N/A")"
            match.striker = nextBatter
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
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            for player in match.currentBowlingTeam?.players ?? NSSet() {
                if (fielderResponsible == (player as AnyObject).id) {
                    fielderName = (player as AnyObject).name ?? ""
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "st \(fielderName) b \(match.bowler?.name ?? "N/A")"
            match.striker = nextBatter
        case "Caught":
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.bowler?.wickets += 1
            match.currentBattingTeam?.wicketsLost += 1
            match.deliveriesBowledThatCount += 1
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            for player in match.currentBowlingTeam?.players ?? NSSet() {
                if (fielderResponsible == (player as AnyObject).id) {
                    fielderName = (player as AnyObject).name ?? ""
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "c \(fielderName) b \(match.bowler?.name ?? "N/A")"
            match.striker = nextBatter
            save(context: context)
            if (crossedOver) {
                _switchStrikerAndNonStriker(match: match, context: context)
            }
        case "Bowled":
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.bowler?.wickets += 1
            match.currentBattingTeam?.wicketsLost += 1
            match.deliveriesBowledThatCount += 1
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "b \(match.bowler?.name ?? "N/A")"
            match.striker = nextBatter
        case "LBW":
            match.striker?.ballsFaced += 1
            match.bowler?.ballsBowled += 1
            match.bowler?.wickets += 1
            match.currentBattingTeam?.wicketsLost += 1
            match.deliveriesBowledThatCount += 1
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "lbw b \(match.bowler?.name ?? "N/A")"
            match.striker = nextBatter
        case "Retired Out":
            match.currentBattingTeam?.wicketsLost += 1
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "retired out/hurt"
            match.striker = nextBatter
        case "Retired Hurt":
            for player in match.currentBattingTeam?.players ?? NSSet() {
                if (newBatter == (player as AnyObject).id) {
                    nextBatter = player as? Player
                }
            }
            if (nextBatter?.outDescription == "not out") {
                nextBatter?.battingPosition = match.battersSentIn + 1
                match.battersSentIn += 1
            }
            if (nextBatter?.outDescription == "retired hurt") {
                nextBatter?.outDescription = "not out"
            }
            match.striker?.outDescription = "retired hurt"
            match.striker = nextBatter
        default:
            print("")
        }
        let delivery = Delivery(context: context)
        delivery.index = match.deliveriesBowled
        delivery.outcome = "W"
        let innings = match.overTracker
        let mutableCopy = innings?.mutableCopy() as! NSMutableSet
        mutableCopy.add(delivery)
        match.overTracker = mutableCopy
        match.deliveriesBowled += 1
        save(context: context)
    }
    
    private func _switchStrikerAndNonStriker(match: Match, context: NSManagedObjectContext) {
        let temp = match.striker
        match.striker = match.nonStriker
        match.nonStriker = temp
        save(context: context)
    }
    
}
