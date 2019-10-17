
import UIKit

class ListVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tblVwList: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblNoRecords: UILabel!
    
    //MARK:- Variables
    var arrSelected = [[String:Any]]()
    var selectedList = Int()

    //MARK:- ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        objDataHelper.fetchData()
        switch selectedList {
        case 0:
            arrSelected = objDataHelper.arrPending
        case 1:
            arrSelected = objDataHelper.arrCompleted
        case 2:
            arrSelected = objDataHelper.arrMissed
        case 3:
            arrSelected = objDataHelper.arrTotalData
        default:
            break
        }
        tblVwList.reloadData()
    }
    
    //MARK:- Custom Functions
    func changeList(arr: [[String:Any]], text: String) {
        arrSelected = arr
        lblHeader.text = "\(text) list"
        tblVwList.reloadData()
    }
    
    //MARK:- IBActions
    @IBAction func actionAdd(_ sender: Any) {
        pushTo(VC: "CreateVC")
    }
    
    @IBAction func actionCompleted(_ sender: UIButton) {
        objDataHelper.updateStatus(id: sender.tag, status: "1")
        switch selectedList {
        case 0:
            arrSelected = objDataHelper.arrPending
        case 1:
            arrSelected = objDataHelper.arrCompleted
        case 2:
            arrSelected = objDataHelper.arrMissed
        case 3:
            arrSelected = objDataHelper.arrTotalData
        default:
            break
        }
        tblVwList.reloadData()
    }
    
    @IBAction func actionPendingList(_ sender: Any) {
        selectedList = 0
        changeList(arr: objDataHelper.arrPending, text: "Pending")
    }
    
    @IBAction func actionCompletedList(_ sender: Any) {
        selectedList = 1
        changeList(arr: objDataHelper.arrCompleted, text: "Completed")
    }
    
    @IBAction func actionMissedList(_ sender: Any) {
        selectedList = 2
        changeList(arr: objDataHelper.arrMissed, text: "Missed")
    }
    
    @IBAction func actionAllList(_ sender: Any) {
        selectedList = 3
        changeList(arr: objDataHelper.arrTotalData, text: "Total")
    }
}

extension ListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrSelected.count == 0 {
            tblVwList.isHidden = true
        } else {
            tblVwList.isHidden = false
        }
        return arrSelected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTVC", for: indexPath) as! ListTVC
        let dict = arrSelected[indexPath.row]
        cell.lblName.text = dict["title"] as? String
        cell.lblTime.text = dict["reminder"] as? String
        cell.lblNotes.text = dict["note"] as? String
        cell.btnCompleted.tag = dict["id"] as! Int
        if (dict["image"] as? String)!.count > 3 {
            cell.imgVw.image = ConvertBase64StringToImage(imageBase64String: (dict["image"] as? String)!)
        }
        if selectedList == 1 || dict["status"] as! String == "1" {
            cell.btnCompleted.isHidden = true
        } else {
            cell.btnCompleted.isHidden = false
        }
        return cell
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let dict = self.arrSelected[indexPath.row]
            objDataHelper.delete(VC: self, selected: dict["id"] as! Int)
            self.viewWillAppear(true)
            success(true)
        })
        modifyAction.image = UIImage(named: "bin")
        modifyAction.backgroundColor = #colorLiteral(red: 0.3075354397, green: 0.7984692454, blue: 0.8049499393, alpha: 1)
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
}
