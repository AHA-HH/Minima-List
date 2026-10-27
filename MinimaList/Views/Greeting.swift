import Foundation

func greeting(for date: Date, calendar: Calendar = .current) -> String {
    switch calendar.component(.hour, from: date) {
    case 5...11: "Good morning"
    case 12...17: "Good afternoon"
    default: "Good evening"
    }
}
