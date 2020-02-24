//
//  CourseScheduleTableViewModel.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 16/2/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

final class CourseScheduleTableViewModel: ModularTableViewModel {
    convenience init(courses: Set<Course>) throws {
        self.init()
        
        var coursesCellItems = [HomeCoursesCellItem]()
        
//        Store courses for weekdays
        for integerDayOfWeek in 1...5 {
            let weekdayName = Course.weekdayFullName[integerDayOfWeek]
            let courseForNIntegerDayOfWeek = courses.enrolledIn.filter { $0.weekdays.contains(Course.weekdayAbbreviations[integerDayOfWeek])}.map { $0.getCourseWithCorrectTime(days: integerDayOfWeek) }.flatMap { $0 }
            
            if !courseForNIntegerDayOfWeek.isEmpty {
                coursesCellItems.append(HomeCoursesCellItem(weekday: weekdayName, courses: courseForNIntegerDayOfWeek, isOnHomeScreen: false))
            }
        }
        
//        Store courses for weekends
        let courseForSaturday = courses.enrolledIn.filter { $0.weekdays.contains("S") }.map { $0.getCourseWithCorrectTime(days: 6) }.flatMap { $0 }
        if !courseForSaturday.isEmpty {
            coursesCellItems.append(HomeCoursesCellItem(weekday: "Saturday", courses: courseForSaturday, isOnHomeScreen: false))
        }
        
        let courseForSunday = courses.enrolledIn.filter { $0.weekdays.contains("S") }.map { $0.getCourseWithCorrectTime(days: 0) }.flatMap { $0 }
        if !courseForSunday.isEmpty {
            coursesCellItems.append(HomeCoursesCellItem(weekday: "Sunday", courses: courseForSunday, isOnHomeScreen: false))
        }
        
        self.items = coursesCellItems
    }
}
