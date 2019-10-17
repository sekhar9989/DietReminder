import CoreData
import UIKit
import UserNotifications


let objDataHelper = CoreDataHelper()

class CoreDataHelper: NSObject, UNUserNotificationCenterDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    func openDatabse(VC: UIViewController,arrKeys : [String],arrValues : [String]) {
        context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ReminderList", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        
        if UserDefaults.standard.value(forKey: "id") == nil {
            UserDefaults.standard.set(1, forKey: "id")
        } else if UserDefaults.standard.value(forKey: "id") != nil {
            UserDefaults.standard.set(UserDefaults.standard.value(forKey: "id") as! Int + 1, forKey: "id")
        }
        
        newTask.setValue(UserDefaults.standard.value(forKey: "id"), forKey: "id")
        
        for i in 0..<arrKeys.count {
            newTask.setValue(arrValues[i], forKey: arrKeys[i])
            setNotification(strDate: arrValues[5], title: arrValues[0], subTitle: arrValues[1], body: arrValues[2], id: "\(UserDefaults.standard.value(forKey: "id")!)")
        }
        
        toastMessage("Saviing..")
        do {
            try context.save()
        } catch {
            VC.alert(message: "Something went wrong, Please try again.", title: "Failed")
        }
    }
    
    //MARK:- Constants and Variables
    var arrTotalData = [Dictionary<String, Any>]()
    var arrPending = [Dictionary<String,Any>]()
    var arrCompleted = [Dictionary<String,Any>]()
    var arrMissed = [Dictionary<String,Any>]()
    
    
    let arrType = ["Personal","Professional","Social"]
    
    //MARK:- Custom Functions
    func fetchData() {
        arrTotalData.removeAll()
        arrPending.removeAll()
        arrCompleted.removeAll()
        arrMissed.removeAll()
        
        context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                let id      = data.value(forKey: "id") as! Int
                let name = data.value(forKey: "title") as! String
                let descriptionNote = data.value(forKey: "note") as! String
                let image = data.value(forKey: "image") as! String
                let status = data.value(forKey: "status") as! String
                let reminder = data.value(forKey: "reminder") as! String
                
                let dict = ["image":image, "id": id,"note": descriptionNote,"title":name,"status":status,"reminder":reminder] as [String : Any]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy  hh:mm a"
                let reminderDate = dateFormatter.date(from: reminder)!
                
                if dict["status"] as! String == "0" {
                    if reminderDate < Date() {
                        updateStatus(id: id, status: "2")
                    }
                }
                
                arrTotalData.append(dict)
                
                switch dict["status"] as! String {
                case "0" :
                    if reminderDate > Date() {
                        arrPending.append(dict)
                    }
                case "1" :
                    arrCompleted.append(dict)
                case "2" :
                    arrMissed.append(dict)
                default:
                    break
                }
            }
        } catch {
            toastMessage("\(error.localizedDescription)")
        }
    }
    
    func delete(VC: UIViewController, selected: Int) {
        context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")
        var fetchedEntities = NSArray()
        let predicate = NSPredicate(format: "id == %d", selected)
        fetchRequest.predicate = predicate
        fetchedEntities = try! context.fetch(fetchRequest) as NSArray
        do {
            for sequence in fetchedEntities {
                context?.delete(sequence as! NSManagedObject)
                do {
                    try context.save()
                    toastMessage("Deleted Successfully")
                } catch {
                    VC.alert(message: "Something went wrong, Please try again.", title: "Updating data Failed")
                }
            }
        }
    }
    
    func update(VC: UIViewController,arrKeys : [String],arrValues : [String], selectedID: Int) {
        context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")
        var fetchedEntities = NSArray()
        let predicate = NSPredicate(format: "id == %d", selectedID)
        fetchRequest.predicate = predicate
        fetchedEntities = try! context.fetch(fetchRequest) as NSArray
        for i in 0..<arrKeys.count {
            fetchedEntities.setValue(arrValues[i], forKey: arrKeys[i])
        }
        toastMessage("Saving..")
        do {
            try context.save()
            fetchData()
            let alertController = UIAlertController(title: "Done", message: "Updated Successfully.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (Action) in
                VC.pushTo(VC: "FullDetailsVC")
            })
            alertController.addAction(OKAction)
            VC.present(alertController, animated: true, completion: nil)
        } catch {
            VC.alert(message: "Something went wrong, Please try again.", title: "Updating data Failed")
        }
    }
    
    func updateStatus(id: Int, status: String) {
        context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")
        var fetchedEntities = NSArray()
        let predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.predicate = predicate
        fetchedEntities = try! context.fetch(fetchRequest) as NSArray
        fetchedEntities.setValue(status, forKey: "status")
        
        do {
            try context.save()
            fetchData()
        } catch {
            toastMessage("Something went wrong, Please try again later")
        }
    }
    
    func setNotification(strDate: String, title: String, subTitle: String, body: String,id: String) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
            } else {
                toastMessage("Please accept notifications for this app from settings to get notifications on time")
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy  hh:mm a"
        let date = dateFormatter.date(from: strDate)!
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.body = body
        
        content.categoryIdentifier = id

        let triggerDaily = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }

}
