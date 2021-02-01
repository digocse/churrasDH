//
//  ChatViewController.swift
//  ChurrasDH
//
//  Created by Rodrigo Santos on 27/01/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    var messages: [Message] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        loadMessages()
    }
    
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            UserDefaultsHelper.logoutUser()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error %@", signOutError)
        }
        
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageText = messageTextField.text, let emailAuthor = Auth.auth().currentUser?.email, let userUID = Auth.auth().currentUser?.uid {
            
            db.collection("users").whereField("userUID", isEqualTo: userUID).getDocuments { (querySnapshot, error) in
                if let e = error {
                    print(e)
                } else {
                    if let snapshotDocs = querySnapshot?.documents {
                        print("Quantidade de usuarios \(snapshotDocs.count)")
                        
                        for doc in snapshotDocs {
                            print(doc.data())
                            let data = doc.data()
                            
                            if let username = data["username"] as? String {
                                self.persistData(messageText: messageText, messageSender: username, emailAuthor: emailAuthor)
                            }
                        }
                    }
                }
            }
    
            
        }
    }
    
//   Outra maneira de persistir a data "createdAt": FieldValue.serverTimestamp()
    private func persistData(messageText: String, messageSender: String, emailAuthor: String) {
        db.collection("messages").addDocument(data: ["text": messageText,
                                                     "sender": messageSender,
                                                     "email": emailAuthor,
                                                     "createdAt": Date().timeIntervalSince1970]) { (error) in
            if let e = error {
                print(e)
            } else {
                print("Mensagem armazenada com sucesso!")
                self.messageTextField.text = ""
            }
        }
    }
    
    private func loadMessages() {
        db.collection("messages").order(by: "createdAt").addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print(e)
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        
                        if let messageText = data["text"] as? String, let messageSender = data["sender"] as? String {
                            let newMessage = Message(sender: messageSender, messageLabel: messageText)
                            self.messages.append(newMessage)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        // messages = [1, 2, 3]
                        // index    =  0  1  2  X
                        // count = 3
                        
                        if self.messages.count > 0 {
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
//        message.sender
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        
        cell.messageLabel.text = message.messageLabel
        return cell
    }
}
