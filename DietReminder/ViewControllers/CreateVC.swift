
import UIKit

class CreateVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tblVwTimes: UITableView!
    @IBOutlet weak var txtFldTime: UITextField!
    @IBOutlet weak var scrlVw: UIScrollView!
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var txtVwDescription: UITextView!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var txtFldName: UITextField!
    @IBOutlet weak var txtFldQuantity: UITextField!
    
    //MARK:- Variables and contants
    var arrTimes = [String]()
    let objCameraGallery = GalleryCamera()
    var selectedImage = String()
    let picker = UIDatePicker()
    let dateformatter = DateFormatter()
    let toolBar = UIToolbar()
    var dict : Dictionary<String, Any>?
    var notes = String()
    
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtVwDescription.text = "Enter here"
        txtVwDescription.textColor = UIColor.lightGray
        objCameraGallery.delegate = self
        picker.timeZone = NSTimeZone.local
        picker.datePickerMode = UIDatePicker.Mode.dateAndTime
        picker.minimumDate = Date()
        // ToolBar
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = #colorLiteral(red: 0.3075354397, green: 0.7984692454, blue: 0.8049499393, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        txtFldTime.inputAccessoryView = toolBar
        txtFldTime.inputView = picker
    }
    
    //MARK:- IBActions
    @objc func done() {
        dateformatter.dateFormat = "dd-MM-yyyy  hh:mm a"
        txtFldTime.text = dateformatter.string(from: picker.date)
        txtFldTime.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        txtFldTime.resignFirstResponder()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        popToBack()
    }
    
    @IBAction func actionAddImage(_ sender: Any) {
        objCameraGallery.showAlertChooseImage(self)
    }
    
    @IBAction func actionAddTime(_ sender: Any) {
        if txtFldTime.text!.isEmpty {
            toastMessage("Please select time")
        } else {
            arrTimes.append(txtFldTime.text!)
            tblVwTimes.reloadData()
            txtFldTime.text?.removeAll()
        }
    }
    
    @IBAction func actionSave(_ sender: Any) {
        if txtFldName.text!.isEmpty {
            toastMessage("Please enter name")
        } else if txtFldQuantity.text!.isEmpty {
            toastMessage("Please enter quantity")
        } else if txtFldTime.text!.isEmpty && arrTimes.count == 0 {
            toastMessage("Please select time")
        } else {
            
            var arrKeys = ["title","quantity","note","image","status"]
            
            if txtVwDescription.textColor == UIColor.black {
                notes = txtVwDescription.text
            }
            
            var arrValues = [txtFldName.text!,txtFldQuantity.text!,notes,selectedImage,"0"]
            
            if arrTimes.count != 0 && txtFldTime.text!.isEmpty {
                for i in 0..<arrTimes.count {
                    if arrKeys.count > 5 {
                        arrKeys.removeLast()
                        arrValues.removeLast()
                    }
                    arrKeys.append("reminder")
                    arrValues.append(arrTimes[i])
                    saveData(arrKeys, arrValues)
                }
            } else if arrTimes.count != 0 && !txtFldTime.text!.isEmpty {
                for i in 0..<arrTimes.count {
                    if arrKeys.count > 5 {
                        arrKeys.removeLast()
                        arrValues.removeLast()
                    }
                    arrKeys.append("reminder")
                    arrValues.append(arrTimes[i])
                    saveData(arrKeys, arrValues)
                }
                if arrKeys.count > 5 {
                    arrKeys.removeLast()
                    arrValues.removeLast()
                }
                arrKeys.append("reminder")
                arrValues.append(txtFldTime.text!)
                saveData(arrKeys, arrValues)
            } else {
                arrKeys.append("reminder")
                arrValues.append(txtFldTime.text!)
                saveData(arrKeys, arrValues)
            }
            let alertController = UIAlertController(title: "Done", message: "Saved Successfully.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (Action) in
                self.popToBack()
            })
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            objDataHelper.fetchData()
            
        }
    }
    
    //MARK:- Custom Functions
    func saveData(_ arrKeys: [String], _ arrValues: [String]) {
        if dict != nil {
            objDataHelper.update(VC: self, arrKeys: arrKeys , arrValues: arrValues, selectedID: dict!["id"] as! Int)
        } else {
            objDataHelper.openDatabse(VC: self, arrKeys: arrKeys , arrValues: arrValues)
        }
    }
}

extension CreateVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTVC", for: indexPath) as! CreateTVC
        cell.lblTime.text = arrTimes[indexPath.row]
        return cell
    }
}

extension CreateVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtVwDescription.textColor == UIColor.lightGray {
            txtVwDescription.text = nil
            txtVwDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtVwDescription.text.isEmpty {
            txtVwDescription.text = "Enter here"
            txtVwDescription.textColor = UIColor.lightGray
        }
    }
}

extension CreateVC: ImageSelected {
    func finishPassing(selectedImg: UIImage) {
        selectedImage = ConvertImageToBase64String(img: selectedImg)
        btnAddImage.setImage(selectedImg, for: .normal)
    }
}
