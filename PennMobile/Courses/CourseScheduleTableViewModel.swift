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
        
        for integerDayOfWeek in 0...6 {
//            Fetch all courses whose meetingTimes contains the relevant weekday abbreviation
            let weekdayName = Course.weekdayFullName[integerDayOfWeek]
            let courseForNIntegerDayOfWeek = courses.enrolledIn.filter { $0.isTaughtOnWeekday(weekday: integerDayOfWeek) }
                .map { $0.getCourseWithCorrectTime(days: integerDayOfWeek) }
                .flatMap { $0 }
            
//            Don't add weekend cells if empty
            if !courseForNIntegerDayOfWeek.isEmpty || (integerDayOfWeek >= 1 && integerDayOfWeek <= 5) {
                coursesCellItems.append(HomeCoursesCellItem(weekday: weekdayName, courses: courseForNIntegerDayOfWeek, isOnHomeScreen: false))
            }
        }
                
        self.items = coursesCellItems
    }
}
