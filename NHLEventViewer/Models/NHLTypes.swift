//
//  nhl.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 15/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Foundation
import Cocoa

struct NHLGame : Codable {
    var gameDate: Date
    var gamePk: Int
    var detailedState: String
    var homeTeamName: String
    var homeTeamScore: Int?
    var awayTeamName: String
    var awayTeamScore: Int?

    static func headers() -> [String] {
        return ["Date", "pk", "State", "Home", "H.Score", "Away", "A.Score"]
    }
    static func columns() -> [String] {
        return ["gameDate", "gamePk", "detailedState", "homeTeamName", "homeTeamScore", "awayTeamName", "awayTeamScore"]
    }
    var dictionary: [String: String] {
        let columns = NHLGame.columns()
        return [columns[0]: gameDate.toString(format: "dd.MM.yyyy")!,
                columns[1]: String(gamePk),
                columns[2]: detailedState,
                columns[3]: homeTeamName,
                columns[4]: String(homeTeamScore ?? 0),
                columns[5]: awayTeamName,
                columns[6]: String(awayTeamScore ?? 0)
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    init(gameDate: Date, gamePk: Int, detailedState: String, homeTeamName: String, homeTeamScore: Int, awayTeamName: String, awayTeamScore: Int) {
        self.gameDate = gameDate
        self.gamePk = gamePk
        self.detailedState = detailedState
        self.homeTeamName = homeTeamName
        self.homeTeamScore = homeTeamScore
        self.awayTeamName = awayTeamName
        self.awayTeamScore = awayTeamScore
    }
    init(gameDate: Date, gamePk: Int, detailedState: String, homeTeamName: String, awayTeamName: String) {
        self.gameDate = gameDate
        self.gamePk = gamePk
        self.detailedState = detailedState
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
    }
}
struct GameEvent {
    var gamePk: Int
    var triCode: String
    var eventTypeID: String
    var period: Int
    var periodTime: String
    var strength: String
    var homeGoals: Int
    var awayGoals: Int
    var emptyNet: Bool
    var description: String
    
    static func headers() -> [String] {
        return ["pk", "Team", "Type", "Period", "P.Time", "Strength", "H.Goals", "A.Goals", "Empty Net", "Description"]
    }
    static func columns() -> [String] {
        return ["gamePk", "triCode", "eventTypeID", "period", "periodTime", "strength", "homeGoals", "awayGoals", "emptyNet", "description"]
    }
    var dictionary: [String: String] {
        let columns = GameEvent.columns()
        return [columns[0]: String(gamePk),
                columns[1]: triCode,
                columns[2]: eventTypeID,
                columns[3]: String(period),
                columns[4]: periodTime,
                columns[5]: strength,
                columns[6]: String(homeGoals),
                columns[7]: String(awayGoals),
                columns[8]: String(emptyNet ? "empty_net" : ""),
                columns[9]: description
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    init(gamePk: Int, triCode: String, eventTypeID: String, period: Int, periodTime: String, strength: String, homeGoals: Int, awayGoals: Int,
         emptyNet: Bool, description: String) {
        self.gamePk = gamePk
        self.triCode = triCode
        self.eventTypeID = eventTypeID
        self.period = period
        self.periodTime = periodTime
        self.strength = strength
        self.homeGoals = homeGoals
        self.awayGoals = awayGoals
        self.emptyNet = emptyNet
        self.description = description
    }
}

struct ScheduleFeed: Codable {
    let copyright: String
    let totalItems, totalEvents, totalGames, totalMatches: Int
    let wait: Int
    let dates: [DateElement]
}
struct DateElement: Codable {
    let date: String
    let totalItems, totalEvents, totalGames, totalMatches: Int
    let games: [ScheduledGame]
    //let events, matches: [JSONAny]
    private enum CodingKeys: String, CodingKey {
        case date
        case totalItems
        case totalEvents
        case totalGames
        case totalMatches
        case games
    }
}
struct ScheduledGame: Codable {
    let gamePk: Int
    let link, gameType, season: String
    let gameDate: Date
    let status: Status
    let teams: Teams
    let venue: Venue
    let content: Content
    
    private enum CodingKeys: String, CodingKey {
        case gamePk
        case link
        case gameType
        case season
        case gameDate
        case status
        case teams
        case venue
        case content
    }
}
struct Teams: Codable {
    let away, home: Away
}
struct Away: Codable {
    let leagueRecord: LeagueRecord
    let score: Int
    let team: Venue
}
struct LeagueRecord: Codable {
    let wins, losses, ot: Int
    let type: String
}
struct Content: Codable {
    let link: String
}

struct LiveFeed: Decodable {
    let copyright: String
    let gamePk: Int
    let link: String
    let metaData: MetaData
    let gameData: GameData
    let liveData: LiveData
    
    private enum CodingKeys: String, CodingKey {
        case copyright
        case gamePk
        case link
        case metadata = "metaData"
        case gamedata = "gameData"
        case livedata = "liveData"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        copyright = try container.decode(String.self, forKey: .copyright)
        gamePk = try container.decode(Int.self, forKey: .gamePk)
        link = try container.decode(String.self, forKey: .link)
        metaData = try container.decode(MetaData.self, forKey: .metadata)
        gameData = try container.decode(GameData.self, forKey: .gamedata)
        liveData = try container.decode(LiveData.self, forKey: .livedata)
    }
}

struct MetaData: Codable {
    let wait: Int
    let timeStamp: String
}

struct GameData: Decodable {
    let game: Game
    let datetime: Datetime
    let status: Status
    let teams: GameDataTeams
    let playerContainer: PlayerContainer
    let venue: Venue

    private enum CodingKeys: String, CodingKey {
        case game
        case datetime
        case status
        case teams
        case playerContainer = "players"
        case venue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        game = try container.decode(Game.self, forKey: .game)
        datetime = try container.decode(Datetime.self, forKey: .datetime)
        status = try container.decode(Status.self, forKey: .status)
        teams = try container.decode(GameDataTeams.self, forKey: .teams)
        playerContainer = try container.decode(PlayerContainer.self, forKey: .playerContainer)
        venue = try container.decode(Venue.self, forKey: .venue)
    }
}
struct Game: Codable {
    let pk: Int
    let season: String
    let type: String
}
struct Datetime: Codable {
    let dateTime: Date
    let endDateTime: Date
}
struct Status: Codable {
    let abstractGameState, codedGameState, detailedState, statusCode: String
    let startTimeTBD: Bool
}
struct GameDataTeams: Codable {
    let away, home: Team
}
struct Team: Codable {
    let id: Int
    let name: String
    let link: String
    let venue: Venue
    let abbreviation, triCode: String
    let teamName, locationName, firstYearOfPlay: String
    let division: Division
    let conference: Conference
    let franchise: Franchise
    let shortName: String
    let officialSiteURL: String
    let franchiseID: Int
    let active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, link, venue, abbreviation, triCode, teamName, locationName, firstYearOfPlay, division, conference, franchise, shortName
        case officialSiteURL = "officialSiteUrl"
        case franchiseID = "franchiseId"
        case active
    }
}
struct Venue: Codable {
    let id: Int?
    let name: String
    let link: String
    let city: String?
    let timeZone: TimeZone?
}
struct TimeZone: Codable {
    let id: String
    let offset: Int
    let tz: String
}
struct Division: Codable {
    let id: Int
    let name: String
    let nameShort: String?
    let link, abbreviation: String
    let triCode: String?
}
struct Franchise: Codable {
    let franchiseID: Int
    let teamName, link: String
    
    enum CodingKeys: String, CodingKey {
        case franchiseID = "franchiseId"
        case teamName, link
    }
}
struct Conference: Codable {
    let id: Int
    let name: String
    let link: String
    let triCode, abbreviation: String?
}
struct PlayerContainer: Decodable {
    struct PlayerKey : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let id = PlayerKey(stringValue: "id")!
        static let fullName = PlayerKey(stringValue: "fullName")!
        static let currentAge = PlayerKey(stringValue: "currentAge")!
        static let currentTeam = PlayerKey(stringValue: "currentTeam")!
    }
    
    struct Player : Codable {
        let playerID: String
        let id: Int
        let fullName: String
        let currentAge: Int
        let currentTeam: CurrentTeam
    }
    
    let players : [Player]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PlayerKey.self)
        
        var players: [Player] = []
        for key in container.allKeys {
            let nested = try container.nestedContainer(keyedBy: PlayerKey.self,
                                                       forKey: key)
            let id = try nested.decode(Int.self, forKey: .id)
            let fullName = try nested.decode(String.self, forKey: .fullName)
            let currentAge = try nested.decode(Int.self, forKey: .currentAge)
            let currentTeam = try nested.decode(CurrentTeam.self, forKey: .currentTeam)
            players.append(Player(
                playerID: key.stringValue,
                id: id,
                fullName: fullName,
                currentAge: currentAge,
                currentTeam: currentTeam))
        }
        
        self.players = players
    }
}
struct CurrentTeam: Codable {
    let id: Int
    let name: String
    let triCode: String
}

struct LiveData: Codable {
    let plays: Plays
    let linescore: String = ""//Linescore
    let boxscore: String = "" //Boxscore
    let decisions: String = "" //Decisions
    
    private enum CodingKeys: String, CodingKey {
        case plays
        case linescore
        case boxscore
        case decisions
    }
}
struct Plays: Codable {
    let allPlays: [AllPlay]
    let scoringPlays, penaltyPlays: [Int]
    let playsByPeriod: String = "" //[PlaysByPeriod]
    let currentPlay: CurrentPlay
}
struct AllPlay: Codable {
    let result: AllPlayResult
    let about: About
    let coordinates: AllPlayCoordinates?
    let players: [AllPlayPlayerElement]?
    let team: String = "" //CurrentTeamClass?
}
struct AllPlayResult: Codable {
    let event: String
    let eventCode: String
    let eventTypeID: String
    let description: String
    let secondaryType: String?
    let penaltySeverity: String?
    let penaltyMinutes: Int?
    let strength: Strength?
    let gameWinningGoal, emptyNet: Bool?
    
    enum CodingKeys: String, CodingKey {
        case event, eventCode
        case eventTypeID = "eventTypeId"
        case description, secondaryType, penaltySeverity, penaltyMinutes, strength, gameWinningGoal, emptyNet
    }
}
struct About: Codable {
    let eventIdx, eventID, period: Int
    let periodType: String
    let ordinalNum: String
    let periodTime, periodTimeRemaining: String
    let dateTime: Date
    let goals: Goals?
    
    enum CodingKeys: String, CodingKey {
        case eventIdx
        case eventID = "eventId"
        case period, periodType, ordinalNum, periodTime, periodTimeRemaining, dateTime, goals
    }
}
struct AllPlayCoordinates: Codable {
    let x, y: Int?
}
struct AllPlayPlayerElement: Codable {
    let player: PlayerElement
    let playerType: String
    let seasonTotal: Int?
}
struct Strength: Codable {
    let code, name: String
}
struct Goals: Codable {
    let away, home: Int
}
struct PlayerElement: Codable {
    let id: Int
    let fullName: String
}
struct CurrentPlay: Codable {
    let result: CurrentPlayResult
    let about: About
    //let coordinates: StatsClass
}

struct CurrentPlayResult: Codable {
    let event: String
    let eventCode: String
    let eventTypeID: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case event, eventCode
        case eventTypeID = "eventTypeId"
        case description
    }
}

extension DateFormatter {
    
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
    
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension String {
    
    func toDate (format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
    func toDateString (inputFormat: String, outputFormat:String) -> String? {
        if let date = toDate(format: inputFormat) {
            return DateFormatter(format: outputFormat).string(from: date)
        }
        return nil
    }
}

extension Date {
    
    func toString (format:String) -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
/*
extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
*/
