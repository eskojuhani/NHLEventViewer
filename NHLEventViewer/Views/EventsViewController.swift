//
//  EventsViewController.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 12/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Cocoa


protocol EventDelegate: class {
    func gameSelected(index: Int?)
    func daysSelected(start: Date, end: Date)
}

class EventsViewController: NSViewController, EventDelegate {
    var eventsView: EventsView!
    var scheduledGamesData: [NHLGame] = []
    var gameEventData: [GameEvent] = []
    
    init() {
        super.init(nibName: "EventsView", bundle: nil)
        eventsView = try! EventsView.view(with: self)
        
        eventsView.delegate = self
        view = eventsView
        
        let columns = NHLGame.headers()
        for (index, tableColumn) in eventsView.scheduledGames.tableColumns.enumerated() {
            tableColumn.headerCell.stringValue = columns[index]
        }
        let columns2 = GameEvent.headers()
        for (index, tableColumn) in eventsView.gameEvents.tableColumns.enumerated() {
            tableColumn.headerCell.stringValue = columns2[index]
        }
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func gameSelected(index: Int?) {
        if let index = index {
            let data = scheduledGamesData[index]
            fetchGameLiveFeed(data.gamePk)
        }
    }
    func daysSelected(start: Date, end: Date) {
        fetchSchedule(start: start, end: end)
    }
    
    func fetchSchedule(start: Date, end: Date) {
        guard let startDate = start.toString(format: "yyyy-MM-dd"), let endDate = end.toString(format: "yyyy-MM-dd")
        else {
            print("invalid dates")
            return
        }
    
        let scheduleClient = ScheduleClient()
        scheduleClient.getFeed(from: .schedule, parameters: ["startDate": startDate, "endDate": endDate]) { result in
            switch result {
            case .success(let feedResult):
                guard let results = feedResult else { return }
                self.doSchedule(results)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    func doSchedule(_ schedulefeed: ScheduleFeed) {
        self.scheduledGamesData.removeAll()
        for scheduledDate in schedulefeed.dates {
            for scheduledGame in scheduledDate.games {
                let localDate = scheduledGame.gameDate.adding(minutes: -6 * 60)
                let nhlGame = NHLGame(gameDate: localDate, gamePk: scheduledGame.gamePk, detailedState: scheduledGame.status.detailedState, homeTeamName: scheduledGame.teams.home.team.name, homeTeamScore: scheduledGame.teams.home.score, awayTeamName: scheduledGame.teams.away.team.name, awayTeamScore: scheduledGame.teams.away.score)
                
                self.scheduledGamesData.append(nhlGame)
                
                //print(scheduledGame.gameDate, scheduledGame.gamePk, scheduledGame.status.detailedState, scheduledGame.teams.home.team.name, scheduledGame.teams.home.score,
                //      scheduledGame.teams.away.team.name, scheduledGame.teams.away.score)
            }
        }
        eventsView.scheduledGames.reloadData()
    }
    func fetchGameLiveFeed(_ id: Int) {
        let liveFeedClient = LiveFeedClient()
        let parameter = String(format:"/%d/feed/live", id)
        liveFeedClient.getFeed(from: .livefeed, parameters: parameter) { result in
            switch result {
            case .success(let feedResult):
                guard let results = feedResult else { return }
                self.doLiveFeed(id, livefeed: results)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    func doLiveFeed(_ id: Int,  livefeed: LiveFeed) {
        self.gameEventData.removeAll()
        let awayTeam = livefeed.gameData.teams.away.triCode
        let homeTeam = livefeed.gameData.teams.home.triCode
        for play in livefeed.liveData.plays.allPlays {
            var triCode = ""
            if (play.result.eventTypeID == "GOAL") {
                if let playerID = play.players?.first?.player.id {
                    if let currentTeam: CurrentTeam = getCurrentTeam(playerId: playerID, livefeed: livefeed) {
                        triCode = currentTeam.triCode
                    }
                }
                let gameEvents = GameEvent(gamePk: id, triCode: triCode, eventTypeID: play.result.eventTypeID, period: play.about.period, periodTime: play.about.periodTime, strength:  play.result.strength?.code ?? "", homeGoals: play.about.goals?.home ?? 0, awayGoals: play.about.goals?.away ?? 0, emptyNet: play.result.emptyNet ?? false, description: play.result.description)
                
                self.gameEventData.append(gameEvents)
            }
            else if (play.result.eventTypeID == "PENALTY") {
                if let playerID = play.players?.first?.player.id {
                    if let currentTeam: CurrentTeam = getCurrentTeam(playerId: playerID, livefeed: livefeed) {
                        triCode = currentTeam.triCode
                    }
                }
                let description =  play.result.secondaryType ?? play.result.description
                let gameEvents = GameEvent(gamePk: id, triCode: triCode, eventTypeID: play.result.eventTypeID, period: play.about.period, periodTime: play.about.periodTime, strength:  play.result.strength?.code ?? "", homeGoals: play.about.goals?.home ?? 0, awayGoals: play.about.goals?.away ?? 0, emptyNet: play.result.emptyNet ?? false, description: String(format:"%02d min ", play.result.penaltyMinutes ?? 0) + description)
                
                self.gameEventData.append(gameEvents)
            }
            else if (play.result.eventTypeID == "HIT") {
                if let playerID = play.players?.first?.player.id {
                    if let currentTeam: CurrentTeam = getCurrentTeam(playerId: playerID, livefeed: livefeed) {
                        triCode = currentTeam.triCode
                    }
                }
                let gameEvents = GameEvent(gamePk: id, triCode: triCode, eventTypeID: play.result.eventTypeID, period: play.about.period, periodTime: play.about.periodTime, strength:  play.result.strength?.code ?? "", homeGoals: play.about.goals?.home ?? 0, awayGoals: play.about.goals?.away ?? 0, emptyNet: play.result.emptyNet ?? false, description: play.result.description)
                
                self.gameEventData.append(gameEvents)
            }
            else if (play.result.eventTypeID.hasSuffix("SHOT")) {
                if let playerID = play.players?.first?.player.id {
                    if let currentTeam: CurrentTeam = getCurrentTeam(playerId: playerID, livefeed: livefeed) {
                        triCode = currentTeam.triCode
                    }
                }
                if (play.result.eventTypeID == "BLOCKED_SHOT") {
                    triCode = (triCode == homeTeam ? awayTeam : homeTeam)
                }
                let gameEvents = GameEvent(gamePk: id, triCode: triCode, eventTypeID: play.result.eventTypeID, period: play.about.period, periodTime: play.about.periodTime, strength:  play.result.strength?.code ?? "", homeGoals: play.about.goals?.home ?? 0, awayGoals: play.about.goals?.away ?? 0, emptyNet: play.result.emptyNet ?? false, description: play.result.description)
                
                self.gameEventData.append(gameEvents)
            }
        }
        //let currentPlay = livefeed.liveData.plays.currentPlay
        //print(currentPlay.result.eventTypeID, homeTeam, currentPlay.about.goals?.home, awayTeam, currentPlay.about.goals?.away)
        self.eventsView.gameEvents.reloadData()
    }
    
    func getCurrentTeam(playerId: Int, livefeed: LiveFeed) -> CurrentTeam? {
        for player in livefeed.gameData.playerContainer.players {
            if (player.id == playerId) {
                return player.currentTeam
            }
        }
        print("Team not found for:", playerId)
        return nil
    }
}

extension EventsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (tableView.identifier?.rawValue == "ScheduledGames") {
            return scheduledGamesData.count
        }
        else {
            return gameEventData.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = tableColumn!.identifier
        var data: NSDictionary?
        if (tableView.identifier?.rawValue == "ScheduledGames") {
            data = scheduledGamesData[row].nsDictionary
        }
        else {
            data = gameEventData[row].nsDictionary
        }
        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            let cellID = cellIdentifier.rawValue
            guard let data = data else { return nil }
            let iV = data[cellID]
            cell.textField?.stringValue = iV as! String
            
            return cell
        }
        return nil
    }
}

