//
//  CalendarDisplayVC.swift
//  Squat Counter
//
//  Created by sam hastings on 18/08/2023.
//

import HorizonCalendar
import UIKit
import RealmSwift

final class CalendarDisplayVC: BaseDemoViewController {

//MARK: - Lifecycle

  required init(monthsLayout: MonthsLayout) {
    super.init(monthsLayout: monthsLayout)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

// MARK: - Internal


    var workouts: Results<RealmWorkout>? = nil
    var filteredWorkouts: Results<RealmWorkout>?
    var dateSelected: Date?
    let todaysDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        title = "Calendar"

        do {
            let realm = try Realm()
            workouts = realm.objects(RealmWorkout.self)
        } catch let error as NSError {
            print("Error loading Realm \(error.localizedDescription)")
        }


        calendarView.scroll(
          toDayContaining: todaysDate,
          scrollPosition: .centered,
          animated: false)
        calendarView.daySelectionHandler = { [weak self] day in

            if let (startOfDayUTC, endOfDayUTC) = self?.dateRangeInUTC(for: day) {
                let predicate = NSPredicate(format: "startTime >= %@ AND endTime <= %@", startOfDayUTC as NSDate, endOfDayUTC as NSDate)
                if let loadedWorkouts = self?.workouts {
                    self?.filteredWorkouts = loadedWorkouts.filter(predicate)
                }
                let dateComponents = DateComponents(year: day.components.year,
                                                    month: day.components.month,
                                                    day: day.components.day)
                if let date = self!.calendar.date(from: dateComponents) {
                    self?.dateSelected = date
                }
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if let daySummaryVC = storyboard.instantiateViewController(withIdentifier: "DaySummaryVC") as? DaySummaryVC {
                daySummaryVC.dateSelected = self?.dateSelected
                daySummaryVC.filteredWorkouts = self?.filteredWorkouts
                self?.navigationController?.pushViewController(daySummaryVC, animated: true)
            }

        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadCalendar()
    }

  override func makeContent() -> CalendarViewContent {
      let startDate = calendar.date(from: DateComponents(year:  2023, month: 6, day: 1))!
      let endDate = calendar.date(byAdding: .day, value: 29, to: todaysDate)!

      return CalendarViewContent(
        calendar: calendar,
        visibleDateRange: startDate...endDate,
        monthsLayout: monthsLayout)
      .interMonthSpacing(24)
      .verticalDayMargin(8)
      .horizontalDayMargin(8)
      .dayItemProvider { [calendar, dayDateFormatter] day in
          var invariantViewProperties = DayView.InvariantViewProperties.baseInteractive



          if let (startOfDayUTC, endOfDayUTC) = self.dateRangeInUTC(for: day) {
                  let predicate = NSPredicate(format: "startTime >= %@ AND endTime <= %@", startOfDayUTC as NSDate, endOfDayUTC as NSDate)

                  if let loadedWorkouts = self.workouts {
                      let matchingWorkouts = loadedWorkouts.filter(predicate)
                      if !matchingWorkouts.isEmpty {
                          invariantViewProperties.backgroundShapeDrawingConfig.borderColor = .orange
                          invariantViewProperties.backgroundShapeDrawingConfig.fillColor = .orange.withAlphaComponent(0.5)
                      }
                  }
              }
          let date = calendar.date(from: day.components)
          return DayView.calendarItemModel(
            invariantViewProperties: invariantViewProperties,
            viewModel: .init(
                dayText: "\(day.day)",
                accessibilityLabel: date.map { dayDateFormatter.string(from: $0) },
                accessibilityHint: nil))
      }
  }

    // MARK: - Helper Functions

    func reloadCalendar() {
        self.calendarView.setContent(self.makeContent())
    }

    func dateRangeInUTC(for day: Day) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: day.components.year, month: day.components.month, day: day.components.day)

        guard let date = calendar.date(from: dateComponents) else { return nil }

        let startOfDayLocal = calendar.startOfDay(for: date)
        let endOfDayLocal = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDayLocal)!

        let localTimeZone = TimeZone.current
        let localTimeZoneOffset = TimeInterval(localTimeZone.secondsFromGMT(for: date))

        let startOfDayUTC = startOfDayLocal.addingTimeInterval(-localTimeZoneOffset)
        let endOfDayUTC = endOfDayLocal.addingTimeInterval(-localTimeZoneOffset)

        return (start: startOfDayUTC, end: endOfDayUTC)
    }



}
