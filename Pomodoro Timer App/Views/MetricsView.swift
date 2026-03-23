//
//  MetricsView.swift
//  Pomodoro Timer App
//

import SwiftUI

struct MetricsView: View {
    @ObservedObject private var statsManager = DailyStatsManager.shared

    private let dotSpacing: CGFloat = 5
    private let horizontalPadding: CGFloat = 16

    @State private var selectedFilter: MetricsFilter = .year
    @State private var loadedWeeks = 12
    @State private var loadedMonths = 6
    @State private var loadedYears = 1
    @State private var contentWidth: CGFloat = 0
    @State private var isLoadingMore = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    filterBar
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        contentWidth = geometry.size.width
                                    }
                                    .onChange(of: geometry.size.width) {
                                        contentWidth = geometry.size.width
                                    }
                            }
                        )
                    dotContent
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical)
            }
            .background(Color.theme.primaryColor.ignoresSafeArea())
            .navigationTitle("Metrics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Layout Calculations

    private var columns: Int {
        selectedFilter == .year ? 14 : 7
    }

    private var dotSize: CGFloat {
        guard contentWidth > 0 else { return 10 }
        return floor((contentWidth - CGFloat(columns - 1) * dotSpacing) / CGFloat(columns))
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.fixed(dotSize), spacing: dotSpacing),
            count: columns
        )
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 0) {
            ForEach(MetricsFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter.label)
                        .font(.subheadline)
                        .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        .foregroundColor(selectedFilter == filter ? Color.theme.primaryColor : Color.theme.invertedPrimary.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            selectedFilter == filter
                                ? Color.theme.invertedPrimary
                                : Color.clear
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding(3)
        .background(Color.theme.invertedPrimary.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Dot Content

    @ViewBuilder
    private var dotContent: some View {
        if contentWidth > 0 {
            switch selectedFilter {
            case .week:
                weekView
            case .month:
                monthView
            case .year:
                yearView
            }
        }
    }

    // MARK: - Week View

    private var weekView: some View {
        let weeks = generateWeeks(count: loadedWeeks)

        return LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(weeks) { week in
                VStack(alignment: .leading, spacing: 6) {
                    Text(week.label)
                        .font(.caption)
                        .foregroundColor(Color.theme.roundSubtitle)

                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: dotSpacing) {
                        ForEach(week.days) { day in
                            dotView(for: day)
                        }
                    }
                }
            }

            if loadedWeeks < 156 {
                scrollSentinel {
                    loadedWeeks = min(loadedWeeks + 12, 156)
                }
            }
        }
    }

    // MARK: - Month View

    private var monthView: some View {
        let months = generateMonthGroups(count: loadedMonths)

        return LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(months) { month in
                VStack(alignment: .leading, spacing: 6) {
                    Text(month.label)
                        .font(.caption)
                        .foregroundColor(Color.theme.roundSubtitle)

                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: dotSpacing) {
                        ForEach(month.days) { day in
                            dotView(for: day)
                        }
                    }
                }
            }

            if loadedMonths < 36 {
                scrollSentinel {
                    loadedMonths = min(loadedMonths + 6, 36)
                }
            }
        }
    }

    // MARK: - Year View

    private var yearView: some View {
        let years = generateYearGroups(count: loadedYears)

        return LazyVStack(alignment: .leading, spacing: 20) {
            ForEach(years) { year in
                VStack(alignment: .leading, spacing: 6) {
                    Text(year.label)
                        .font(.caption)
                        .foregroundColor(Color.theme.roundSubtitle)

                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: dotSpacing) {
                        ForEach(year.days) { day in
                            dotView(for: day)
                        }
                    }
                }
            }

            if loadedYears < 3 {
                scrollSentinel {
                    loadedYears = min(loadedYears + 1, 3)
                }
            }
        }
    }

    // MARK: - Shared Components

    private func scrollSentinel(action: @escaping () -> Void) -> some View {
        Color.clear
            .frame(height: 1)
            .onAppear {
                guard !isLoadingMore else { return }
                isLoadingMore = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    action()
                    isLoadingMore = false
                }
            }
    }

    @ViewBuilder
    private func dotView(for day: CalendarDay) -> some View {
        if day.isFuture {
            Circle()
                .fill(Color.theme.grayAccent.opacity(0.25))
                .frame(width: dotSize, height: dotSize)
        } else {
            let completed = statsManager.didCompleteSeries(on: day.date)
            if completed {
                Text("🏆")
                    .font(.system(size: dotSize * 0.8))
                    .frame(width: dotSize, height: dotSize)
            } else {
                Circle()
                    .fill(Color.theme.grayAccent.opacity(0.3))
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        day.isToday
                            ? Circle().stroke(Color.theme.invertedPrimary, lineWidth: 1.5)
                            : nil
                    )
            }
        }
    }

    // MARK: - Data Generation

    private func generateWeeks(count: Int) -> [DotGroup] {
        let calendar = Calendar.current
        let today = Date()
        var groups: [DotGroup] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        for weekOffset in 0..<count {
            guard let weekEnd = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) else { continue }
            guard let weekStart = calendar.date(byAdding: .day, value: -6, to: weekEnd) else { continue }

            let endFormatter = DateFormatter()
            endFormatter.dateFormat = "MMM d"
            let label = weekOffset == 0 ? "This Week" : "\(formatter.string(from: weekStart)) – \(endFormatter.string(from: weekEnd))"

            var days: [CalendarDay] = []
            for dayOffset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
                let isToday = calendar.isDateInToday(date)
                let isFuture = date > today && !isToday
                days.append(CalendarDay(date: date, isToday: isToday, isFuture: isFuture))
            }

            groups.append(DotGroup(label: label, days: days))
        }

        return groups
    }

    private func generateMonthGroups(count: Int) -> [DotGroup] {
        let calendar = Calendar.current
        let today = Date()
        var groups: [DotGroup] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        for offset in 0..<count {
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: today) else { continue }
            let components = calendar.dateComponents([.year, .month], from: monthDate)
            guard let year = components.year, let month = components.month else { continue }
            guard let startOfMonth = calendar.date(from: components) else { continue }
            guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { continue }

            let label = formatter.string(from: startOfMonth)
            var days: [CalendarDay] = []

            for day in range {
                var dayComponents = DateComponents()
                dayComponents.year = year
                dayComponents.month = month
                dayComponents.day = day
                guard let date = calendar.date(from: dayComponents) else { continue }
                let isToday = calendar.isDateInToday(date)
                let isFuture = date > today && !isToday
                days.append(CalendarDay(date: date, isToday: isToday, isFuture: isFuture))
            }

            groups.append(DotGroup(label: label, days: days))
        }

        return groups
    }

    private func generateYearGroups(count: Int) -> [DotGroup] {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        var groups: [DotGroup] = []

        for yearOffset in 0..<count {
            let year = currentYear - yearOffset
            let label = "\(year)"

            var startComponents = DateComponents()
            startComponents.year = year
            startComponents.month = 1
            startComponents.day = 1
            guard let startOfYear = calendar.date(from: startComponents) else { continue }

            var endComponents = DateComponents()
            endComponents.year = year
            endComponents.month = 12
            endComponents.day = 31
            guard let endOfYear = calendar.date(from: endComponents) else { continue }

            var days: [CalendarDay] = []
            var currentDate = startOfYear

            while currentDate <= endOfYear {
                let isToday = calendar.isDateInToday(currentDate)
                let isFuture = currentDate > today && !isToday
                days.append(CalendarDay(date: currentDate, isToday: isToday, isFuture: isFuture))
                guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = next
            }

            groups.append(DotGroup(label: label, days: days))
        }

        return groups
    }
}

// MARK: - Filter Enum

enum MetricsFilter: CaseIterable {
    case week
    case month
    case year

    var label: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

// MARK: - Models

private struct DotGroup: Identifiable {
    let id = UUID()
    let label: String
    let days: [CalendarDay]
}

private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isToday: Bool
    let isFuture: Bool
}

#Preview {
    MetricsView()
}
