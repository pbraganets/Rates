//
//  Rate+CoreDataProperties.swift
//  Rates
//
//  Created by Pavel B on 12/16/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//
//

import Foundation
import CoreData


extension Rate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rate> {
        return NSFetchRequest<Rate>(entityName: "Rate")
    }

    @NSManaged public var name: String
    @NSManaged public var value: Double

}
