//
//  CoreDataController.swift
//  Konvertor
//
//  Created by Олександр Потапов on 1/26/19.
//  Copyright © 2019 Perchiki. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController{
    let context = { () -> NSManagedObjectContext in
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
    func storeRatesToCoreData(rates: [String: Double]){
        for abr in rates.keys{
            storeRateToCoreData(rate: rates[abr]!, abr: abr)
        }
    }
    func storeRateToCoreData(rate: Double, abr: String){
        
        let entity = NSEntityDescription.entity(forEntityName: "CurrencyRate", in: context())
        let newRate = NSManagedObject(entity: entity!, insertInto: context())
        newRate.setValue(abr, forKey: "abbreviation")
        newRate.setValue(rate, forKey: "rateToUSD")
        do {
//            print("value stored")
            try context().save()
        } catch {
            print("Failed saving")
        }

    }
    func fetchRatesFromCoreData() -> [String:Double]{
        var exchangeRates = [String:Double]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context().fetch(request)
            for data in result as! [NSManagedObject] {
                let key = data.value(forKey: "abbreviation") as! String
                let value = data.value(forKey: "rateToUSD") as! Double
               exchangeRates[key] = value
            }

        } catch {

            print("Failed")
        }
        return exchangeRates
    }
}
