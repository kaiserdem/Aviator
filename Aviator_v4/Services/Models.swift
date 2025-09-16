
import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let seasonRatings: [SeasonRating]
}

// MARK: - SeasonRating
struct SeasonRating: Codable {
    let eventID: Int
    let event: Event
    let startTimestamp: Int
    let rating: Double
    let opponent: Opponent
    let isHome: Bool

    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case event, startTimestamp, rating, opponent, isHome
    }
}

// MARK: - Event
struct Event: Codable {
    let tournament: Tournament
    let customID: String
    let status: Status
    let winnerCode: Int
    let homeTeam, awayTeam: Opponent
    let homeScore, awayScore: Score
    let id: Int
    let slug: String
    let startTimestamp: Int
    let finalResultOnly: Bool

    enum CodingKeys: String, CodingKey {
        case tournament
        case customID = "customId"
        case status, winnerCode, homeTeam, awayTeam, homeScore, awayScore, id, slug, startTimestamp, finalResultOnly
    }
}

// MARK: - Score
struct Score: Codable {
    let current, display, period1, period2: Int
    let period3, period4, normaltime: Int
    let series, overtime: Int?
}

// MARK: - Opponent
struct Opponent: Codable {
    let name, slug, shortName: String
    let gender: Gender
    let sport: Sport
    let userCount: Int
    let nameCode: String
    let disabled, national: Bool
    let type, id: Int
    let teamColors: TeamColors
    let fieldTranslations: OpponentFieldTranslations
}

// MARK: - OpponentFieldTranslations
struct OpponentFieldTranslations: Codable {
    let nameTranslation: NameTranslation
    let shortNameTranslation: ShortNameTranslationClass
}

// MARK: - NameTranslation
struct NameTranslation: Codable {
    let ar, ru: String
    let bn: String?
}

// MARK: - ShortNameTranslationClass
struct ShortNameTranslationClass: Codable {
    let ar, hi: String
    let bn: String?
}

enum Gender: String, Codable {
    case m = "M"
}

// MARK: - Sport
struct Sport: Codable {
    let name: SportName
    let slug: SportSlug
    let id: Int
}

enum SportName: String, Codable {
    case basketball = "Basketball"
}

enum SportSlug: String, Codable {
    case basketball = "basketball"
}

// MARK: - TeamColors
struct TeamColors: Codable {
    let primary, secondary, text: String
}

// MARK: - Status
struct Status: Codable {
    let code: Int
    let description: Description
    let type: TypeEnum
}

enum Description: String, Codable {
    case aet = "AET"
    case ended = "Ended"
}

enum TypeEnum: String, Codable {
    case finished = "finished"
}

// MARK: - Tournament
struct Tournament: Codable {
    let name: TournamentName
    let slug: TournamentSlug
    let category: Category
    let uniqueTournament: UniqueTournament
    let priority: Int
    let isLive: Bool
    let id: Int
    let fieldTranslations: CategoryFieldTranslations
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: CategoryName
    let slug: Flag
    let sport: Sport
    let flag: Flag
    let alpha2: Alpha2
    let fieldTranslations: CategoryFieldTranslations
}

enum Alpha2: String, Codable {
    case us = "US"
}

// MARK: - CategoryFieldTranslations
struct CategoryFieldTranslations: Codable {
    let nameTranslation: ShortNameTranslationClass
    let shortNameTranslation: ShortNameTranslation
}

// MARK: - ShortNameTranslation
struct ShortNameTranslation: Codable {
}

enum Flag: String, Codable {
    case usa = "usa"
}

enum CategoryName: String, Codable {
    case usa = "USA"
}

enum TournamentName: String, Codable {
    case nba = "NBA"
    case nbaPlayoffs = "NBA, Playoffs"
}

enum TournamentSlug: String, Codable {
    case nba = "nba"
    case nbaPlayoffs = "nba-playoffs"
}

// MARK: - UniqueTournament
struct UniqueTournament: Codable {
    let name: TournamentName
    let slug: TournamentSlug
    let primaryColorHex: PrimaryColorHex
    let secondaryColorHex: SecondaryColorHex
    let category: Category
    let userCount, id: Int
    let displayInverseHomeAwayTeams: Bool
    let fieldTranslations: CategoryFieldTranslations
}

enum PrimaryColorHex: String, Codable {
    case the045Daf = "#045daf"
}

enum SecondaryColorHex: String, Codable {
    case cc2B31 = "#cc2b31"
}
