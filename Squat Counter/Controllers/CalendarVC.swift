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
        
        do {
            let realm = try Realm()
            workouts = realm.objects(RealmWorkout.self)
            
            // Observe Results Notifications
            notificationToken = workouts?.observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    self?.createCalendar()
                case .update(_, _, _, _):
                    // Query results have changed, so update the calendar.
                    self?.createCalendar()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            }
        } catch let error as NSError {
            print("Error loading Realm \(error.localizedDescription)")
        }
        
        //overrideUserInterfaceStyle = .dark
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
        let startDate = calendar.date(from: DateComponents(year:  2023, month: 7, day: 1))!
        let endDate = calendar.date(from: DateComponents(year:  2023, month: 12, day: 31))!
        let content = CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        )
            .interMonthSpacing(10)
//            .dayOfWeekItemProvider({ month, weekdayIndex in
//
//            })
            .dayItemProvider { day in
                
                var content = DayLabel.Content(day: day, textColor: .black)  // Default textColor to blue
                

                let dateComponents = DateComponents(year: day.components.year,
                                                    month: day.components.month,
                                                    day: day.components.day)

                if let date = calendar.date(from: dateComponents),
                       let ordinalDay = calendar.ordinality(of: .day, in: .era, for: date) {
                            if let loadedWorkouts = self.workouts {
                                let matchingWorkouts = loadedWorkouts.filter("workoutDay == %@", ordinalDay)
                                if !matchingWorkouts.isEmpty {
                                    content.textColor = .orange  // Change textColor if there's a workout on this day
                                }
                            }
                    }

                return DayLabel.calendarItemModel(
                        invariantViewProperties: .init(font: UIFont.systemFont(ofSize: 18), backgroundColor: .clear),
                        viewModel: content)
        }
            
        let calendarView = CalendarView(initialContent: content)
        calendarView.daySelectionHandler = { [weak self] day in
            
            let dateComponents = DateComponents(year: day.components.year,
                                                month: day.components.month,
                                                day: day.components.day)
            if let date = calendar.date(from: dateComponents),
                   let ordinalDay = calendar.ordinality(of: .day, in: .era, for: date) {
                self?.dateSelected = date
                if let loadedWorkouts = self?.workouts {
                    self?.filteredWorkouts = loadedWorkouts.filter("workoutDay == %@", ordinalDay)
                    
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
    
    

}


