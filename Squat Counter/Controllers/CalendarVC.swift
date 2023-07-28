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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let realm = try Realm()
            workouts = realm.objects(RealmWorkout.self)
        } catch let error as NSError {
            print("Error loading Realm \(error.localizedDescription)")
        }
        
        //overrideUserInterfaceStyle = .dark
        createCalendar()
    }
    
    private func createCalendar(){
        let calendar = Calendar.current
        let dummyDate = calendar.date(from: DateComponents(year: 2023, month: 8, day: 22))!
        let startDate = calendar.date(from: DateComponents(year:  2023, month: 1, day: 1))!
        let endDate = calendar.date(from: DateComponents(year:  2023, month: 12, day: 31))!
        let content = CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        )
            .interMonthSpacing(10)
            .dayItemProvider { day in
                
                var content = DayLabel.Content(day: day, textColor: .black)  // Default textColor to blue
                
//                var invariantViewProperties = DayLabel.InvariantViewProperties(
//                    font: UIFont.systemFont(ofSize: 18),
//                    //textColor: .darkGray,
//                    backgroundColor: .clear)
//
//
//                let date = calendar.date(from: DateComponents(year: day.components.year, month: day.components.month, day: day.components.day))!
//                if date == dummyDate {
//                    content.textColor = .systemGreen  // Change textColor to blue if it's the dummyDate
//                }
                let dateComponents = DateComponents(year: day.components.year,
                                                    month: day.components.month,
                                                    day: day.components.day)
//                if let date = calendar.date(from: dateComponents) {
//                    // Truncate date to beginning of day to align with workoutDate.
//                    let startOfDay = calendar.startOfDay(for: date)
//
//                    // Look for a workout that matches the current day.
//                    if let loadedWorkouts = self.workouts {
//                        if loadedWorkouts.contains(where: { workout in
//                            guard let workoutDate = workout.workoutDate else { return false }
//                            let workoutStartOfDay = calendar.startOfDay(for: workoutDate)
//                            return workoutStartOfDay == startOfDay
//                        }) {
//                            content.textColor = .systemGreen  // Change textColor if there's a workout on this day
//                        }
//                    }
//                }
                if let date = calendar.date(from: dateComponents),
                       let ordinalDay = calendar.ordinality(of: .day, in: .era, for: date) {
                            if let loadedWorkouts = self.workouts {
                                let matchingWorkouts = loadedWorkouts.filter("workoutDay == %@", ordinalDay)
                                if !matchingWorkouts.isEmpty {
                                    content.textColor = .systemGreen  // Change textColor if there's a workout on this day
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
            // NAVIGATION
            //self?.performSegue(withIdentifier: "showDaySummary", sender: self)
            
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
    
    // NAVIGATION
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "showDaySummary" {
//                if let daySummaryVC = segue.destination as? DaySummaryVC {
//                    // pass your data here
//                    daySummaryVC.filteredWorkouts = self.filteredWorkouts
//                    daySummaryVC.dateSelected = self.dateSelected
//                }
//            }
//        }
    

}


