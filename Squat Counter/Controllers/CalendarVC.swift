//
//  CalendarVC.swift
//  Squat Counter
//
//  Created by sam hastings on 25/07/2023.
//

import UIKit
import HorizonCalendar
import RealmSwift

class CalendarVC: UIViewController {
    
    var workouts: Results<RealmWorkout>?
    var filteredWorkouts: Results<RealmWorkout>?
    var dateSelected: Date?
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

//        // Set the title color to white
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        // Prevent the navigation bar from changing appearance on scroll
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = "Calendar"
        
        do {
            let realm = try Realm()
            workouts = realm.objects(RealmWorkout.self)
            
            // Observe Results Notifications
            notificationToken = workouts?.observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    DispatchQueue.main.async {
                                self?.createCalendar()
                    }
                case .update(_, _, _, _):
                    // Query results have changed, so update the calendar.
                    DispatchQueue.main.async {
                                self?.createCalendar()
                    }
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            }
        } catch let error as NSError {
            print("Error loading Realm \(error.localizedDescription)")
        }
        
        overrideUserInterfaceStyle = .dark
        //createCalendar()
    }
    
    deinit {
            // Always invalidate any notification tokens when you are done with them.
            notificationToken?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalendarToDayView" {
            let destinationVC = segue.destination as! DaySummaryVC
            destinationVC.dateSelected = dateSelected
            destinationVC.filteredWorkouts = filteredWorkouts
        }
    }
    
    private func createCalendar(){
        let calendar = Calendar.current
        // date(from:) - returns a date created from the specified components
        let startDate = calendar.date(from: DateComponents(year:  2023, month: 6, day: 1))!
        let todaysDate = Date()
        let endDate = calendar.date(byAdding: .day, value: 29, to: todaysDate)!
        let content = CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        )
            .interMonthSpacing(10)
            .verticalDayMargin(8)
            .horizontalDayMargin(8)
            .dayItemProvider { day in
                
                
                var content = DayLabel.Content(day: day, textColor: .white, layerBackgroundColour: UIColor.black.cgColor, layerBorderColour: UIColor.black.cgColor)  // Default textColor to white
                
                if let (startOfDayUTC, endOfDayUTC) = self.dateRangeInUTC(for: day) {
                        let predicate = NSPredicate(format: "startTime >= %@ AND endTime <= %@", startOfDayUTC as NSDate, endOfDayUTC as NSDate)

                        if let loadedWorkouts = self.workouts {
                            let matchingWorkouts = loadedWorkouts.filter(predicate)
                            if !matchingWorkouts.isEmpty {
                                content.textColor = .orange
                                content.layerBorderColour = UIColor.orange.cgColor
                            }
                        }
                    }

                return DayLabel.calendarItemModel(
                        invariantViewProperties: .init(font: UIFont.systemFont(ofSize: 18), backgroundColor: .clear),
                        viewModel: content)
            }

            
        let calendarView = CalendarView(initialContent: content)
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
                if let date = calendar.date(from: dateComponents) {
                    self?.dateSelected = date
                }
            }
            self?.performSegue(withIdentifier: "CalendarToDayView", sender: self)
        }

        // add calendar to our view hierarchy
        view.addSubview(calendarView)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            calendarView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
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
