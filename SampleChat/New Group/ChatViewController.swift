



import UIKit
import Firebase

class ChatViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    var messages: [Message] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
        
    }
    func loadMessages() {
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            self.messages = []
            if let e = error {
                print("there was an issue! \(e)") 
            }else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let bodyMessage = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: bodyMessage)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                            }
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data:
                                                                
                 [K.FStore.senderField: messageSender,
                  K.FStore.bodyField: messageBody,
                  K.FStore.dateField:Date().timeIntervalSince1970]) { error in if let e = error {
                print("An Issue: \(e)")
            } else {
                print("Succesfully added")
                
            }
                
            }
        }
        messageTextfield.text = ""
        
    }
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        as! MessageCell
        let message = messages[indexPath.row]
        cell.label.text = message.body
        if message.sender == Auth.auth().currentUser?.email{
            cell.lefImageView.isHidden = true
            cell.rightImageViwe.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named:K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named:K.BrandColors.purple)
            
        }
            else {
                cell.lefImageView.isHidden = false
                cell.rightImageViwe.isHidden = true
                cell.messageBubble.backgroundColor = UIColor(named:K.BrandColors.purple)
                cell.label.textColor = UIColor(named:K.BrandColors.lightPurple)
            }
        return cell
                 
        
        
    }
    
    
}
