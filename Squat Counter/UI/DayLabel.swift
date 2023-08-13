//
//  CalendarUI.swift
//  Squat Counter
//
//  Created by sam hastings on 26/07/2023.
//

import HorizonCalendar
import UIKit

struct DayLabel: CalendarItemViewRepresentable {

    /// Properties that are set once when we initialize the view.
    struct InvariantViewProperties: Hashable {
        let font: UIFont
        //let textColor: UIColor
        let backgroundColor: UIColor
    }

    /// Properties that will vary depending on the particular date being displayed.
    struct Content: Equatable {
        let day: Day
        var textColor: UIColor  // Variable textColor in Content
        var layerBackgroundColour: CGColor
        var layerBorderColour: CGColor
    }
    
    // The type of view that will be created by this view representable.
    typealias ViewType = UILabel

    // The type of content (i.e. the model) that will be associated with a created view.
    typealias ViewModel = Content

    static func makeView(
        withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
        -> UILabel
    {
        let label = UILabel()

        label.backgroundColor = invariantViewProperties.backgroundColor
        label.font = invariantViewProperties.font

        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12

        return label
    }

    static func setViewModel(_ viewModel: Content, on view: UILabel) {

        view.text = "\(viewModel.day.day)"
        view.textColor = viewModel.textColor
        view.layer.backgroundColor = viewModel.layerBackgroundColour
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 23 // change this from hard coded to progrzmmatic
        view.layer.borderColor = viewModel.layerBorderColour
        
        
    }

}


