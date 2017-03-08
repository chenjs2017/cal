//
//  FormulaInfo+CoreDataClass.swift
//  MyCalculator
//
//  Created by jingshun chen on 3/3/17.
//  Copyright © 2017 jingshun chen. All rights reserved.
//

import Foundation
import CoreData

@objc(FormulaInfo)
public class FormulaInfo: NSManagedObject {
    static let MAX = 10
    @nonobjc public class func newFormula(managedContext : NSManagedObjectContext) -> FormulaInfo {
        let entity = NSEntityDescription.entity(forEntityName: "FormulaInfo", in: managedContext)!
        let formula = (NSManagedObject(entity: entity, insertInto: managedContext) as! FormulaInfo)
        formula.formulaIndex = Int32(NSDate().timeIntervalSince1970)
        formula.isFavorite = false
        formula.formulaName = "(unamed)"
        
        let count = getNormalCount(managedContext: managedContext)
        if (count > MAX) {
            if let logs = FormulaInfo.getOldestNormal(managedContext: managedContext, count - MAX){
                for log in logs {
                    managedContext.delete(log)
                }
            }
        }
        return formula
    }
    
    
    @nonobjc public class func getLatest(managedContext : NSManagedObjectContext) -> FormulaInfo? {
        let fetch : NSFetchRequest<FormulaInfo> = fetchRequest()
        
        fetch.fetchLimit = 1
        fetch.sortDescriptors = [NSSortDescriptor(key:"formulaIndex", ascending: false )]
        do {
            let logs = try managedContext.fetch(fetch)
            if logs.count > 0 {
                return logs.last!
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    @nonobjc public class func getOldestNormal(managedContext : NSManagedObjectContext,_ limit: Int) -> [FormulaInfo]? {
        let fetch : NSFetchRequest<FormulaInfo> = FormulaInfo.fetchRequest()
        fetch.predicate = NSPredicate(format: "isFavorite=false")
        fetch.fetchLimit = limit
        fetch.sortDescriptors = [NSSortDescriptor(key:"formulaIndex", ascending: true  )]
        do {
            return try managedContext.fetch(fetch)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    @nonobjc public class func getNormalCount(managedContext : NSManagedObjectContext) -> Int  {
        let fetch : NSFetchRequest<NSFetchRequestResult>= fetchRequest()
        fetch.predicate = NSPredicate(format: "isFavorite=false")
        fetch.sortDescriptors = [NSSortDescriptor(key:"formulaIndex", ascending: false )]
        do {
            let count = try managedContext.count(for: fetch)
            return count
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return 0
    }
    
    @nonobjc public class func getAll(managedContext : NSManagedObjectContext) -> [FormulaInfo]? {
        let fetch : NSFetchRequest<FormulaInfo> = fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(key:"isFavorite", ascending: false ),
            NSSortDescriptor(key:"formulaIndex", ascending: false )]
        
        do {
            let logs = try managedContext.fetch(fetch)
            return logs
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    @nonobjc public class func getLatestOrNew(managedContext : NSManagedObjectContext)->FormulaInfo{
        if let info  = FormulaInfo.getLatest(managedContext: managedContext) {
            return info
        } else {
            return FormulaInfo.newFormula(managedContext: managedContext)
        }
        
    }
    
    func getCalOperationInfo()->Array<CalCenter.OprationInfo>{
        var arr : Array<CalCenter.OprationInfo> = []
        for  item  in (self.operationInfos!) {
            let info = item as! OperationInfo
            var op : CalCenter.Operator? = nil
            var or : Double? = nil
            if (info.theOperator != nil) {
                op = CalCenter.Operator(rawValue: info.theOperator!)
            }
            if (info.theOperand != nil) {
                or = Double(info.theOperand!)
            }
            
            arr.append(CalCenter.OprationInfo(theOperand: or ,theOperator: op))
        }
        return arr
    }
    
    func saveOperationInfos(_ history: Array<CalCenter.OprationInfo>) {
        
        self.removeFromOperationInfos(self.operationInfos!)
        for info in history {
            let operationInfo = OperationInfo(context: self.managedObjectContext!)
            if (info.theOperand != nil) {
                operationInfo.theOperand = String(info.theOperand!)
            }
            if (info.theOperator != nil) {
                operationInfo.theOperator = info.theOperator!.rawValue
            }
            self.addToOperationInfos(operationInfo)
        }
        self.save()
        
    }
    
    func getString() -> String {
        let cal = CalCenter()
        cal.initByHistory(self.getCalOperationInfo())
        return cal.toString().0
    }
    
    func updateFormulaIndex() {
        self.formulaIndex = Int32(Date().timeIntervalSince1970)
        save()
    }
    
    
    func save() {
        do {
            try managedObjectContext!.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}
