//
//  FormulaInfo+CoreDataProperties.swift
//  MyCalculator
//
//  Created by jingshun chen on 3/7/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import Foundation
import CoreData


extension FormulaInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FormulaInfo> {
        return NSFetchRequest<FormulaInfo>(entityName: "FormulaInfo");
    }

    @NSManaged public var formulaIndex: Int32
    @NSManaged public var isFavorite: Bool
    @NSManaged public var formulaName: String?
    @NSManaged public var operationInfos: NSOrderedSet?

}

// MARK: Generated accessors for operationInfos
extension FormulaInfo {

    @objc(insertObject:inOperationInfosAtIndex:)
    @NSManaged public func insertIntoOperationInfos(_ value: OperationInfo, at idx: Int)

    @objc(removeObjectFromOperationInfosAtIndex:)
    @NSManaged public func removeFromOperationInfos(at idx: Int)

    @objc(insertOperationInfos:atIndexes:)
    @NSManaged public func insertIntoOperationInfos(_ values: [OperationInfo], at indexes: NSIndexSet)

    @objc(removeOperationInfosAtIndexes:)
    @NSManaged public func removeFromOperationInfos(at indexes: NSIndexSet)

    @objc(replaceObjectInOperationInfosAtIndex:withObject:)
    @NSManaged public func replaceOperationInfos(at idx: Int, with value: OperationInfo)

    @objc(replaceOperationInfosAtIndexes:withOperationInfos:)
    @NSManaged public func replaceOperationInfos(at indexes: NSIndexSet, with values: [OperationInfo])

    @objc(addOperationInfosObject:)
    @NSManaged public func addToOperationInfos(_ value: OperationInfo)

    @objc(removeOperationInfosObject:)
    @NSManaged public func removeFromOperationInfos(_ value: OperationInfo)

    @objc(addOperationInfos:)
    @NSManaged public func addToOperationInfos(_ values: NSOrderedSet)

    @objc(removeOperationInfos:)
    @NSManaged public func removeFromOperationInfos(_ values: NSOrderedSet)

}
