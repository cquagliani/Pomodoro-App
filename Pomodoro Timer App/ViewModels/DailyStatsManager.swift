//
//  DailyStatsManager.swift
//  Pomodoro Timer App
//

import Foundation

class DailyStatsManager: ObservableObject {
    static let shared = DailyStatsManager()

    private let userDefaults: UserDefaults
    private let completedRoundsKey = "dailyCompletedRounds"
    private let completedSeriesKey = "dailyCompletedSeries"
    private let lastDateKey = "dailyStatsDate"
    private let dailyGoalKey = "dailyFocusGoal"
    private let historyKey = "dailyStatsHistory"
    private let seriesHistoryKey = "dailySeriesHistory"

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    @Published var completedRoundsToday: Int = 0
    @Published var completedSeriesToday: Int = 0
    @Published var dailyGoal: Int = 8
    @Published var dailyHistory: [String: Int] = [:]
    @Published var seriesHistory: [String: Int] = [:]

    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.pomodoro-timer") ?? .standard
        self.dailyGoal = userDefaults.object(forKey: dailyGoalKey) != nil ? userDefaults.integer(forKey: dailyGoalKey) : 8
        self.dailyHistory = (userDefaults.dictionary(forKey: historyKey) as? [String: Int]) ?? [:]
        self.seriesHistory = (userDefaults.dictionary(forKey: seriesHistoryKey) as? [String: Int]) ?? [:]
        resetIfNewDay()
    }

    func recordCompletedRound() {
        resetIfNewDay()
        completedRoundsToday += 1
        userDefaults.set(completedRoundsToday, forKey: completedRoundsKey)
        saveTodayToHistory()
    }

    func recordCompletedSeries() {
        resetIfNewDay()
        completedSeriesToday += 1
        userDefaults.set(completedSeriesToday, forKey: completedSeriesKey)
        saveTodaySeriesToHistory()
    }

    func setDailyGoal(_ goal: Int) {
        dailyGoal = goal
        userDefaults.set(goal, forKey: dailyGoalKey)
    }

    func roundsCompleted(on date: Date) -> Int {
        let key = Self.dateFormatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return completedRoundsToday
        }
        return dailyHistory[key] ?? 0
    }

    func seriesCompleted(on date: Date) -> Int {
        let key = Self.dateFormatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return completedSeriesToday
        }
        return seriesHistory[key] ?? 0
    }

    func didCompleteSeries(on date: Date) -> Bool {
        return seriesCompleted(on: date) > 0
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        // Check today first
        if didCompleteSeries(on: date) {
            streak += 1
        } else {
            return 0
        }

        // Walk backwards
        while true {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDay
            if didCompleteSeries(on: date) {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    private func saveTodayToHistory() {
        let key = Self.dateFormatter.string(from: Date())
        dailyHistory[key] = completedRoundsToday
        userDefaults.set(dailyHistory, forKey: historyKey)
    }

    private func saveTodaySeriesToHistory() {
        let key = Self.dateFormatter.string(from: Date())
        seriesHistory[key] = completedSeriesToday
        userDefaults.set(seriesHistory, forKey: seriesHistoryKey)
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = userDefaults.object(forKey: lastDateKey) as? Date ?? .distantPast
        let lastDay = Calendar.current.startOfDay(for: lastDate)

        if today != lastDay {
            // Save yesterday's final counts to history before resetting
            if lastDay != Calendar.current.startOfDay(for: .distantPast) {
                let lastKey = Self.dateFormatter.string(from: lastDay)
                let lastRounds = userDefaults.integer(forKey: completedRoundsKey)
                if dailyHistory[lastKey] == nil || lastRounds > (dailyHistory[lastKey] ?? 0) {
                    dailyHistory[lastKey] = lastRounds
                    userDefaults.set(dailyHistory, forKey: historyKey)
                }
                let lastSeries = userDefaults.integer(forKey: completedSeriesKey)
                if seriesHistory[lastKey] == nil || lastSeries > (seriesHistory[lastKey] ?? 0) {
                    seriesHistory[lastKey] = lastSeries
                    userDefaults.set(seriesHistory, forKey: seriesHistoryKey)
                }
            }
            completedRoundsToday = 0
            completedSeriesToday = 0
            userDefaults.set(0, forKey: completedRoundsKey)
            userDefaults.set(0, forKey: completedSeriesKey)
            userDefaults.set(today, forKey: lastDateKey)
        } else {
            completedRoundsToday = userDefaults.integer(forKey: completedRoundsKey)
            completedSeriesToday = userDefaults.integer(forKey: completedSeriesKey)
        }
    }
}
