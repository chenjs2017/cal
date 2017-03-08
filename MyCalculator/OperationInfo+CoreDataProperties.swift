//
//  OperationInfo+CoreDataProperties.swift
//  MyCalculator
//
//  Created by jingshun chen on 3/3/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import Foundation
import CoreData


extension OperationInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OperationInfo> {
        return NSFetchRequest<OperationInfo>(entityName: "OperationInfo");
    }

    @NSManaged public var theOperand: String?
    @NSManaged public var theOperator: String?
    @NSManaged public var formula: FormulaInfo?

}
