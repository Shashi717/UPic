//
//  DisplayImageViewController.swift
//  UPic
//
//  Created by Madushani Lekam Wasam Liyanage on 2/8/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class DisplayImageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let reuseIdentifier = "votersFeedCell"
    var image: UIImage!
    var imageUrl: URL!
    var ref: FIRStorageReference!
    var upvotes = 0
    var downvotes = 0
    var category: GallerySections!
    var imageTitle: String!
    var votersFeedTableView: UITableView = UITableView()
    var allVotingsFeed: [String] = []
    var allVoters: [String] = []
    var profileIdToName: [String:String] = [:]
    var profileIdToImage: [String:UIImage] = [:]
    var currentUserName: String?
    var currentUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        self.votersFeedTableView.rowHeight = 50
        selectedImageView.contentMode = .scaleToFill
        selectedImageView.image = image
        selectedImageView.setNeedsLayout()
        getVoters()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        getMetadata()
        
    }
    
    func setupViewHierarchy() {
        
        self.view.addSubview(imageContainerView)
        imageContainerView.addSubview(selectedImageView)
        imageContainerView.addSubview(votesContainerView)
        votesContainerView.addSubview(upvoteButton)
        votesContainerView.addSubview(downvoteButton)
        votesContainerView.addSubview(upvotesLabel)
        votesContainerView.addSubview(downvotesLabel)
        
        upvoteButton.addTarget(self, action: #selector(upvoteButtonTapped(sender:)), for: .touchUpInside)
        downvoteButton.addTarget(self, action: #selector(downvoteButtonTapped(sender:)), for: .touchUpInside)
        votersFeedTableView.delegate = self
        votersFeedTableView.dataSource = self
        self.view.addSubview(votersFeedTableView)
        votersFeedTableView.register(VotersFeedTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func downloadProfileImage(username: String) {
        let userRef = FIRDatabase.database().reference().child("users")
        var idToName: (id: String,name: String) = ("","")
        
        
        userRef.observe(.childAdded, with: { (snapshot) in
            
            guard let user = snapshot.childSnapshot(forPath: "username").value as? String else {
                return
            }

            if user == username {
      
                idToName.id = snapshot.key
                idToName.name = user
                
                userRef.child(idToName.id).observe(.value, with: { (snapshot) in
                    
                    if let profileImageURL = snapshot.childSnapshot(forPath: "profileImageURL").value as? String {
                        
                        if let cachedProfilePic = imageCache.object(forKey: profileImageURL as AnyObject) as? UIImage {
                            DispatchQueue.main.async {
                                self.view.layoutSubviews()
                                self.profileIdToImage[idToName.name] = cachedProfilePic
                                DispatchQueue.main.async {
                                    self.votersFeedTableView.reloadData()
                                }
                            }
                            
                            return
                        }
                        
                        // Download Image If Not Found In Cache. Insert into cache as well
                        let storageRef = FIRStorage.storage().reference(forURL: profileImageURL)
                        
                        storageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
                            
                            if let data = data {
                                let pic = UIImage(data: data)
                                imageCache.setObject(pic!, forKey: profileImageURL as AnyObject)
                                DispatchQueue.main.async {
                                    self.view.layoutSubviews()
                                    self.profileIdToImage[idToName.name] = pic
                                    DispatchQueue.main.async {
                                        self.votersFeedTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                })
            }
        })
    }
    
    
    func getVoters() {
        let databaseRef = FIRDatabase.database().reference()
        let ref = databaseRef.child("categories").child(category.rawValue).child(imageTitle)
        
        ref.observe(.value, with: { (snapshot) in
            
            var votingFeed: [String] = []
            var upvoters: [String] = []
            var downvoters: [String] = []
            var localAllVoters: [String] = []
            
            if snapshot.childSnapshot(forPath: "upvotes").childrenCount > 0 {
                upvoters = snapshot.childSnapshot(forPath: "upvotes").value! as! [String]

            }
            
            if snapshot.childSnapshot(forPath: "downvotes").childrenCount > 0 {
                downvoters = snapshot.childSnapshot(forPath: "downvotes").value! as! [String]
            }
            
            for name in upvoters {
                if name != ""  {
                    localAllVoters.append(name)
                    votingFeed.append("\(name) voted up.")
                    self.downloadProfileImage(username: name)
                }
            }
            
            for name in downvoters {
                if name != ""  {
                    localAllVoters.append(name)
                    votingFeed.append("\(name) voted down.")
                    self.downloadProfileImage(username: name)
                }
            }
            
            self.allVoters = localAllVoters
            self.allVotingsFeed = votingFeed
            DispatchQueue.main.async {
           
                self.votersFeedTableView.reloadData()
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allVotingsFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! VotersFeedTableViewCell
        
        cell.propicImage.image = nil
        cell.textLabel?.text = nil
        
        cell.feedLabel.text = allVotingsFeed[indexPath.row]
        let voterName = allVoters[indexPath.row]
        
        
        if profileIdToImage[allVoters[indexPath.row]] != nil {
            
            cell.propicImage.image = profileIdToImage[voterName]!
        }
        else {
            cell.propicImage.image = UIImage(named: "user_icon")
        }
        
        return cell
    }
    
    internal func upvoteButtonTapped(sender: UIButton) {
        
        if FIRAuth.auth()?.currentUser?.isAnonymous == false && allVoters.contains(currentUserName!) == false {
            
            upvotes += 1
            editMetaData()
            updateVoteLabels()
            
            if let userId = FIRAuth.auth()?.currentUser?.uid {
                
                let userReference = FIRDatabase.database().reference().child("users").child(userId)
                
                userReference.observe(.value, with: { (snapshot) in
                    
                    if let username = snapshot.childSnapshot(forPath: "username").value as? String {
                        self.sendVoters(voteType: "upvotes", username: username)
                    }
                    
                })
                
                FIRDatabase.database().reference().child("users").child(userId).child("upvotes").updateChildValues(["upvote" : self.imageTitle])
            }
        }
    }
    
    internal func downvoteButtonTapped(sender: UIButton) {
        
        if FIRAuth.auth()?.currentUser?.isAnonymous == false && allVoters.contains(currentUserName!) == false {
            
            downvotes += 1
            editMetaData()
            updateVoteLabels()
            
            if let userId = FIRAuth.auth()?.currentUser?.uid {
                
                let userReference = FIRDatabase.database().reference().child("users").child(userId)
                
                userReference.observe(.value, with: { (snapshot) in
                    if let username = snapshot.childSnapshot(forPath: "username").value as? String {
                        
                        self.sendVoters(voteType: "downvotes", username: username)
                    }
                })
                
                FIRDatabase.database().reference().child("users").child(userId).child("downvotes").updateChildValues(["downvote" : self.imageTitle])
                
            }
        }
    }
    
    func sendVoters(voteType: String, username: String) {
        
        let databaseRef = FIRDatabase.database().reference()
        let ref = databaseRef.child("categories").child(category.rawValue).child(imageTitle)
        var voters: [String] = []
        
        ref.observe(.value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: voteType).childrenCount > 0 {
                voters = snapshot.childSnapshot(forPath: voteType).value! as! [String]
            }
            if !voters.contains(username) {
                voters.append(username)
            }
            ref.updateChildValues([voteType:voters])
        })
        
    }
    
    func editMetaData() {
        
        let newMetadata = FIRStorageMetadata()
        newMetadata.contentType = "image/jpeg"
        
        let dict = [
            "upvotes": String(upvotes),
            "downvotes": String(downvotes)
        ]
        
        newMetadata.setValue(dict, forKey: "customMetadata")
        
        self.ref.update(newMetadata) { metadata, error in
            if let error = error {
                print("Error ----- \(error.localizedDescription)")
                
            } else {
                
                print("Successfully Updated Metadata")
          
            }
        }
        
        self.votersFeedTableView.reloadData()
      
    }
    
    func getMetadata() {
        ref.metadata { (metaData, error) in
            if let error = error {
                print("Error ----- \(error.localizedDescription)")
            }
            else {
                
                let upvotesMetadata = metaData?.customMetadata!["upvotes"]!
                let downvotesMetadata = metaData?.customMetadata!["downvotes"]!
                
                self.upvotes = Int(upvotesMetadata!)!
                self.downvotes = Int(downvotesMetadata!)!
                
                self.upvotesLabel.text = upvotesMetadata!
                self.downvotesLabel.text = downvotesMetadata!
            }
        }
    }
    
    func updateVoteLabels() {
        self.upvotesLabel.text = String(upvotes)
        self.downvotesLabel.text = String(downvotes)
    }
    
    func configureConstraints() {
        self.imageContainerView.snp.makeConstraints { (view) in
            let targetHeight = self.navigationController?.navigationBar.frame.size.height
            view.top.equalToSuperview().offset(targetHeight!)
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.5)
        }
        
        self.votersFeedTableView.snp.makeConstraints { (view) in
            view.top.equalTo(imageContainerView.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        
        self.selectedImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalTo(imageContainerView)
            view.bottom.equalTo(imageContainerView.snp.bottom).inset(20.0)
        }
        self.votesContainerView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.equalTo(imageContainerView)
            view.top.equalTo(imageContainerView.snp.bottom).inset(60.0)
        }
        self.upvotesLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(votesContainerView)
            view.height.equalTo(20.0)
            view.width.equalTo(votesContainerView.snp.width).multipliedBy(0.5)
            view.leading.equalTo(votesContainerView.snp.leading)
        }
        self.upvoteButton.snp.makeConstraints { (view) in
            view.top.equalTo(votesContainerView.snp.top).offset(10.0)
            view.centerX.equalTo(upvotesLabel.snp.centerX)
            view.height.equalTo(20)
            view.width.size.equalTo(20.0)
        }
        self.downvotesLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(votesContainerView)
            view.height.equalTo(20.0)
            view.width.equalTo(votesContainerView.snp.width).multipliedBy(0.5)
            view.trailing.equalTo(votesContainerView.snp.trailing)
        }
        self.downvoteButton.snp.makeConstraints { (view) in
            view.top.equalTo(votesContainerView.snp.top).offset(10.0)
            view.centerX.equalTo(downvotesLabel.snp.centerX)
            view.height.equalTo(20)
            view.width.size.equalTo(20.0)
        }
        
    }
    
    internal lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        return view
    }()
    
    internal lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = ColorPalette.primaryColor
        return imageView
    }()
    
    internal lazy var votesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        view.alpha = 0.6
        return view
    }()
    
    internal lazy var upvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "up_arrow"), for: .normal)
        button.tintColor = ColorPalette.accentColor
        return button
    }()
    
    internal lazy var downvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "down_arrow"), for: .normal)
        button.tintColor = ColorPalette.accentColor
        return button
    }()
    
    internal lazy var upvotesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = ColorPalette.primaryColor
        label.textColor = ColorPalette.accentColor
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    internal lazy var downvotesLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = ColorPalette.primaryColor
        label.textColor = ColorPalette.accentColor
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
}
