//
//  UserView.swift
//  JsonParsingOne
//
//  Created by Meet Thanki on 20/10/20.
//

import UIKit

class UserView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView : UITableView!
    var myUserModel : UserModel!
    var myUserList = [UsersList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callApi()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
    }
    
    func callApi(){
        // 1. create the url
        if let url = URL(string: "https://designtrident.com/Test/view_user.php"){
            
            // 2. create url session
            let session = URLSession(configuration: .default)
            
            // 3. give the session task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                
                if let jsonData = data{
                    let decoder = JSONDecoder()
                    do{
                        self.myUserModel = try decoder.decode(UserModel.self, from: jsonData)
                        self.myUserList = self.myUserModel.users_list
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }catch{
                        print(error)
                    }
                    
                }
            }
            
            //4. start the task
            task.resume()
        }
    }
    
    func deleteUser(user_id : String){
        
        let parameters = "user_id=\(user_id)"
        
        if let url = URL(string: "https://designtrident.com/Test/delete_user.php"){
            
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.httpBody = parameters.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                
                if let jsonData = data{
                    let responseJSON = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let response = responseJSON as? [String:Any] {
                        if (response["status"] as? Bool)! {
                            self.callApi()
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.myUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath)
        if let cell = cell as? TableCell{
            cell.title.text = self.myUserList[indexPath.row].user_name
            cell.number.text = self.myUserList[indexPath.row].user_mobile
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Message", message: "Are You Sure You Wants to Remove This User", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.deleteUser(user_id: self.myUserList[indexPath.row].user_id)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
