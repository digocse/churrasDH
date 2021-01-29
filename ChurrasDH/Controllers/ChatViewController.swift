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
    
    var messages: [Message] = [
        Message(sender: "teste@123.com", messageLabel: "Ola OlaOlaOlaOla  OlaOlaOla OlaOlaOlaOlaOla  OlaOlaOlaOlaOlaOla  OlaOlaOlaOlaOlaOlaOla"),
        Message(sender: "outro@123.com", messageLabel: "Oi")
    ]
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error %@", signOutError)
        }
        
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageText = messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
            
            
            db.collection("messages").addDocument(data: ["text": messageText, "sender": messageSender]) { (error) in
                if let e = error {
                    print(e)
                } else {
                    print("Mensagem armazenada com sucesso!")
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        
        cell.messageLabel.text = message.messageLabel
        return cell
    }
}
