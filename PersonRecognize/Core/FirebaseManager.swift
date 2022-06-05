//
//  FirebaseManager.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 24/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Nuke

class FirebaseManager {
    init() {
        FirebaseApp.configure()
    }
    
    func uploadAllVectors(vectors: [Vector], child: String, completionHandler: @escaping () -> Void) {
        for (i, vector) in vectors.enumerated() {
            let dict = vector.dict
            let childString = "\(vector.name) - \(i)"
            database.reference().child(child).child(vector.name).child(childString).updateChildValues(dict, withCompletionBlock: {
                (error, ref) in
                if error == nil {
                    print("uploaded vector")
                }
                completionHandler()
            })
        }
    }

    func uploadKMeanVectors(vectors: [Vector], child: String, completionHandler: @escaping () -> Void) {
        
        for (i, vector) in vectors.enumerated() {
            let dict = vector.dict
            let childString = "\(vector.name) - \(i)"
            database.reference().child(child).child(childString).updateChildValues(dict, withCompletionBlock: {
                (error, ref) in
                if error == nil {
                    print("uploaded vector")
                }
                completionHandler()
            })
        }
    }
    
    func loadLogTimes(completionHandler: @escaping ([Users]) -> Void) {
        var attendList: [Users] = []
        database.reference().child(LOG_TIME).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let data = snapshot.value as? [String: Any] else {
                completionHandler(attendList)
                return
            }
            let dataArray = Array(data)
            let values = dataArray.compactMap { $0.1 as? [String: Any] }
            for item in values {
                guard let name = item["name"] as? String,
                      let imgUrl = item["imageURL"] as? String,
                      let time = item["time"] as? String
                else {
                    print("Error at get log times.")
                    continue
                }
                let object = Users(name: name, imageURL: imgUrl, time: time)
                attendList.append(object)
            }
            completionHandler(attendList.sorted(by: { $0.time > $1.time }))

        }) { (error) in
            print(error.localizedDescription)
            completionHandler(attendList)
        }
        
    }
    
    func loadVector(completionHandler: @escaping ([Vector]) -> Void) {
        var vectors = [Vector]()
        database.reference().child(KMEAN_VECTOR).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let data = snapshot.value as? [String: Any] {
//                print(data.json())

                let dataArray = Array(data)
                let values = dataArray.compactMap { $0.1 as? [String: Any] }.compactMap { Vector(item: $0) }
                vectors.append(contentsOf: values)
            }
            completionHandler(vectors)
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandler(vectors)
        }
    }
    
    func loadAllVector(name: String, completionHandler: @escaping ([Vector]) -> Void) {
        var vectors = [Vector]()
        database.reference().child(ALL_VECTOR).child(name).queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let data = snapshot.value as? [String: Any] {
                let dataArray = Array(data)

                let values = dataArray.compactMap { $0.1 as? [String: Any] }.compactMap { Vector(item: $0) }
                vectors.append(contentsOf: values)
            }
            completionHandler(vectors)
            
        }) { (error) in
            print(error.localizedDescription)
            completionHandler(vectors)
        }

    }
    
    func uploadLogTimes(user: User, completionHandler: @escaping (Error?) -> Void) {
        
        let storageRef = Storage.storage(url: STORAGE_URL).reference().child("\(user.name) - \(user.time.dropLast(10))")
        
        guard let imageData = user.image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        //upload image to firebase storage
        storageRef.putData(imageData, metadata: metadata, completion: {
            (StorageMetadata, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                completionHandler(error)
                return
            }

            storageRef.downloadURL(completion: {
                (url, error) in
                guard let metaImageUrl = url?.absoluteString else {
                    return
                }
                let dict: Dictionary<String, Any>  = [
                    "name": user.name,
                    "imageURL": metaImageUrl,
                    "time": user.time
                ]
                self.database.reference().child(LOG_TIME).child("\(user.name) - \(user.time.dropLast(10))").updateChildValues(dict, withCompletionBlock: {
                    (error, ref) in
                    if error == nil {
                        print("Uploaded log time.")
                        completionHandler(nil)
                    }
                })
            })
        })
    }
    
    func loadUsers(completionHandler: @escaping ([String: Int]) -> Void) {
        database.reference().child(USER_CHILD).queryLimited(toLast: 300).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Int] {
                completionHandler(data)
            } else {
                completionHandler([:])
            }
        }) { (error) in
            print(error.localizedDescription)
            completionHandler([:])
        }
    }
    

    func uploadUser(name: String, user_id: Int, completionHandler: @escaping () -> Void) {
        let dict = [name : user_id]
        database.reference().child(USER_CHILD).updateChildValues(dict, withCompletionBlock: {
            (error, ref) in
            if error == nil {
                print("update user.")
            }
            completionHandler()
        })
    }
    
    var database: Database {
        return Database.database()
    }
}

public extension Collection {
    
    /// Convert self to JSON String.
    /// Returns: the pretty printed JSON string or an empty string if any error occur.
    func json() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("json serialization error: \(error)")
            return "{}"
        }
    }
}
