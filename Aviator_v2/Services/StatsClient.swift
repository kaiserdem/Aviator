import Foundation
import ComposableArchitecture

struct StatsClient {
    var fetchStats: () async -> FlightStats
}

extension StatsClient: DependencyKey {
    static let liveValue = Self(
        fetchStats: {
            await StatsService.shared.fetchStats()
        }
    )
}

extension DependencyValues {
    var statsClient: StatsClient {
        get { self[StatsClient.self] }
        set { self[StatsClient.self] = newValue }
    }
}

// MARK: - Stats Service

final class StatsService {
    static let shared = StatsService()
    
    private init() {}
    
    func fetchStats() async -> FlightStats {
        // Отримуємо дані з AircraftClient
        let aircraftData = await AircraftClient.liveValue.fetchAircraftPositions()
        
        guard !aircraftData.isEmpty else {
            return FlightStats()
        }
        
        // Розраховуємо статистику
        let totalAircraft = aircraftData.count
        
        // Найшвидший літак
        let fastestAircraft = aircraftData.max { $0.velocity ?? 0 < $1.velocity ?? 0 }
        let fastestStat = AircraftStat(
            callsign: fastestAircraft?.callsign ?? "Unknown",
            value: (fastestAircraft?.velocity ?? 0) * 3.6, // Конвертуємо м/с в км/год
            unit: "km/h",
            country: fastestAircraft?.originCountry ?? "Unknown",
            aircraftType: fastestAircraft?.icao24 ?? "Unknown"
        )
        
        // Найвищий літак
        let highestAircraft = aircraftData.max { $0.altitude ?? 0 < $1.altitude ?? 0 }
        let highestStat = AircraftStat(
            callsign: highestAircraft?.callsign ?? "Unknown",
            value: highestAircraft?.altitude ?? 0,
            unit: "m",
            country: highestAircraft?.originCountry ?? "Unknown",
            aircraftType: highestAircraft?.icao24 ?? "Unknown"
        )
        
        // Найнижчий літак
        let lowestAircraft = aircraftData.min { $0.altitude ?? 0 < $1.altitude ?? 0 }
        let lowestStat = AircraftStat(
            callsign: lowestAircraft?.callsign ?? "Unknown",
            value: lowestAircraft?.altitude ?? 0,
            unit: "m",
            country: lowestAircraft?.originCountry ?? "Unknown",
            aircraftType: lowestAircraft?.icao24 ?? "Unknown"
        )
        
        // Регіональна статистика
        let regionalStats = calculateRegionalStats(aircraftData)
        
        // Статистика по типах літаків
        let aircraftTypeStats = calculateAircraftTypeStats(aircraftData)
        
        return FlightStats(
            totalAircraft: totalAircraft,
            fastestAircraft: fastestStat,
            highestAircraft: highestStat,
            lowestAircraft: lowestStat,
            regionalStats: regionalStats,
            aircraftTypeStats: aircraftTypeStats,
            lastUpdated: Date()
        )
    }
    
    private func calculateRegionalStats(_ aircraft: [AircraftPosition]) -> [RegionStat] {
        var regionCounts: [Region: Int] = [:]
        var regionSpeeds: [Region: [Double]] = [:]
        var regionAltitudes: [Region: [Double]] = [:]
        
        for aircraft in aircraft {
            let region = getRegionFromCoordinates(
                latitude: aircraft.latitude ?? 0,
                longitude: aircraft.longitude ?? 0
            )
            
            regionCounts[region, default: 0] += 1
            
            if let speed = aircraft.velocity {
                regionSpeeds[region, default: []].append(speed * 3.6) // км/год
            }
            
            if let altitude = aircraft.altitude {
                regionAltitudes[region, default: []].append(altitude)
            }
        }
        
        return regionCounts.map { region, count in
            let avgSpeed = regionSpeeds[region]?.reduce(0, +) ?? 0 / Double(regionSpeeds[region]?.count ?? 1)
            let avgAltitude = regionAltitudes[region]?.reduce(0, +) ?? 0 / Double(regionAltitudes[region]?.count ?? 1)
            
            return RegionStat(
                region: region,
                aircraftCount: count,
                averageSpeed: avgSpeed,
                averageAltitude: avgAltitude
            )
        }.sorted { $0.aircraftCount > $1.aircraftCount }
    }
    
    private func calculateAircraftTypeStats(_ aircraft: [AircraftPosition]) -> [AircraftTypeStat] {
        var typeCounts: [String: Int] = [:]
        var typeSpeeds: [String: [Double]] = [:]
        var typeAltitudes: [String: [Double]] = [:]
        
        for aircraft in aircraft {
            let type = aircraft.icao24 ?? "Unknown"
            
            typeCounts[type, default: 0] += 1
            
            if let speed = aircraft.velocity {
                typeSpeeds[type, default: []].append(speed * 3.6) // км/год
            }
            
            if let altitude = aircraft.altitude {
                typeAltitudes[type, default: []].append(altitude)
            }
        }
        
        return typeCounts.map { type, count in
            let avgSpeed = typeSpeeds[type]?.reduce(0, +) ?? 0 / Double(typeSpeeds[type]?.count ?? 1)
            let avgAltitude = typeAltitudes[type]?.reduce(0, +) ?? 0 / Double(typeAltitudes[type]?.count ?? 1)
            
            return AircraftTypeStat(
                type: type,
                count: count,
                averageSpeed: avgSpeed,
                averageAltitude: avgAltitude
            )
        }.sorted { $0.count > $1.count }.prefix(10).map { $0 } // Топ 10 типів
    }
    
    private func getRegionFromCoordinates(latitude: Double, longitude: Double) -> Region {
        // Проста логіка визначення регіону за координатами
        if latitude >= 35 && latitude <= 70 && longitude >= -25 && longitude <= 40 {
            return .europe
        } else if latitude >= 10 && latitude <= 60 && longitude >= 60 && longitude <= 180 {
            return .asia
        } else if latitude >= 10 && latitude <= 70 && longitude >= -180 && longitude <= -50 {
            return .america
        } else if latitude >= -35 && latitude <= 35 && longitude >= -20 && longitude <= 55 {
            return .africa
        } else if latitude >= -50 && latitude <= -10 && longitude >= 110 && longitude <= 180 {
            return .oceania
        } else {
            return .all
        }
    }
}
