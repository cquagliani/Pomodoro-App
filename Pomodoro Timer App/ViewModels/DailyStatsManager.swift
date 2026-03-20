//
//  DailyStatsManager.swift
//  Pomodoro Timer App
//

import Foundation

class DailyStatsManager: ObservableObject {
    static let shared = DailyStatsManager()

    private let userDefaults: UserDefaults
    private let completedRoundsKey = "dailyCompletedRounds"
    private let lastDateKey = "dailyStatsDate"
    private let dailyGoalKey = "dailyFocusGoal"

    @Published var completedRoundsToday: Int = 0
    @Published var dailyGoal: Int = 8

    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.pomodoro-timer") ?? .standard
        self.dailyGoal = userDefaults.object(forKey: dailyGoalKey) != nil ? userDefaults.integer(forKey: dailyGoalKey) : 8
        resetIfNewDay()
    }

    func recordCompletedRound() {
        resetIfNewDay()
        completedRoundsToday += 1
        userDefaults.set(completedRoundsToday, forKey: completedRoundsKey)
    }

    func setDailyGoal(_ goal: Int) {
        dailyGoal = goal
        userDefaults.set(goal, forKey: dailyGoalKey)
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = userDefaults.object(forKey: lastDateKey) as? Date ?? .distantPast
        let lastDay = Calendar.current.startOfDay(for: lastDate)

        if today != lastDay {
            completedRoundsToday = 0
            userDefaults.set(0, forKey: completedRoundsKey)
            userDefaults.set(today, forKey: lastDateKey)
        } else {
            completedRoundsToday = userDefaults.integer(forKey: completedRoundsKey)
        }
    }
}
