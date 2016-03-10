/*
* Copyright (c) 2015, Tidepool Project
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the associated License, which is identical to the BSD 2-Clause
* License as published by the Open Source Initiative at opensource.org.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the License for more details.
*
* You should have received a copy of the License along with this program; if
* not, you can obtain one from Tidepool Project at tidepool.org.
*/

import HealthKit
import RealmSwift

class HealthKitData: Object {
    enum Action: Int {
        case Unknown = 0, Added, Deleted
    }

    dynamic var createdAt = NSDate()
    dynamic var timeZoneOffset = NSCalendar.currentCalendar().timeZone.secondsFromGMT / 60
    dynamic var action = Action.Unknown.rawValue
    dynamic var id = ""
    dynamic var healthKitTypeIdentifier = ""
    dynamic var sourceName = ""
    dynamic var sourceBundleIdentifier = ""
    dynamic var sourceVersion = ""
    dynamic var value: Double = 0
    dynamic var units = ""
    dynamic var startDate = NSDate()
    dynamic var endDate = NSDate()

    dynamic var granolaJson = ""

    override static func indexedProperties() -> [String] {
        return ["id", "createdAt", "healthKitTypeIdentifier"]
    }
}
