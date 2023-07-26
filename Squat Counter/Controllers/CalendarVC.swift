//
//  CalendarVC.swift
//  Squat Counter
//
//  Created by sam hastings on 25/07/2023.
//

import UIKit
import HorizonCalendar

final class CalendarVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        createCalendar()
    }
    
    private func createCalendar(){
        //HorizonCalender approach
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year:  2023, month: 1, day: 1))!
        let endDate = calendar.date(from: DateComponents(year:  2023, month: 12, day: 31))!
        let content = CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
        )
            .interMonthSpacing(10)
            //.overlayItemProvider(for: <#T##Set<CalendarViewContent.OverlaidItemLocation>#>, <#T##overlayItemProvider: (CalendarViewContent.OverlayLayoutContext) -> AnyCalendarItemModel##(CalendarViewContent.OverlayLayoutContext) -> AnyCalendarItemModel##(_ overlayLayoutContext: CalendarViewContent.OverlayLayoutContext) -> AnyCalendarItemModel#>)
            //.dayItemProvider(<#T##dayItemProvider: (Day) -> AnyCalendarItemModel##(Day) -> AnyCalendarItemModel##(_ day: Day) -> AnyCalendarItemModel#>)
        let calendarView = CalendarView(initialContent: content)
        calendarView.daySelectionHandler = {day in
            let output = "Selected: " + String(describing: day.components)
            print(output)
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
        
        // UICalenderView approach
//        view.backgroundColor = .black
//        let calendarView = UICalendarView()
//        // Apply layout constraints
//        calendarView.translatesAutoresizingMaskIntoConstraints = false
//
//        //set calendar type
//        calendarView.calendar = .current
//        calendarView.locale = .current
//        calendarView.fontDesign = .rounded // looks the nicest
//        calendarView.delegate = self
//
//        // add calendar to our view hierarchy
//        view.addSubview(calendarView)
//
//        // set some layout constraints
//        NSLayoutConstraint.activate([
//            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            calendarView.heightAnchor.constraint(equalToConstant: 300),
//            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
//        ])
    }
    

}

//extension CalendarVC: UICalendarViewDelegate {
//    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
//        return nil
//    }
//}
