//
//  API.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 02/11/22.
//

import Foundation
import FirebaseStorage

struct ImageUploader{
    

    
    static func uploadImage(image:UIImage,completion:@escaping(String)->Void){
        guard let imageData = image.jpegData(compressionQuality: 0.75)
 else {
            print("No Image data")
            return }

        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_Images/\(filename)")
        ref.putData(imageData, metadata: nil){
            metadata,error in
            if let error = error{
                print("DEBUG:Failed to upload image\(error.localizedDescription)")
                    return
            }
            ref.downloadURL{(url,error) in
                guard let imageUrl = url?.absoluteString else {
                    return
                }
                completion(imageUrl)
            }
        }


            }


}
