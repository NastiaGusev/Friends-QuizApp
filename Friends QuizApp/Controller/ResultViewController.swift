
import UIKit
import FirebaseFirestore

class ResultViewController: UIViewController {

    @IBOutlet weak var score: UITextView!
    @IBOutlet weak var message: UITextView!
    
    let db = Firestore.firestore()
    var userScore: Int = 0
    var highScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        getHighScore()
        updateHighScore()
        score.text = "\(userScore)"
        updateMessage()
    }
    
    @IBAction func startOverPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func updateMessage(){
        if userScore > 10 {
            message.text = K.FinalMessage.veryGood
        } else if userScore > 5 && userScore < 11 {
            message.text = K.FinalMessage.good
        } else {
            message.text = K.FinalMessage.ok
        }
    }
    
    func getHighScore() {
        db.collection(K.FStore.highScoreCollection)
            .addSnapshotListener { querySnapshot, error in
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let updatedHighScore = data[K.FStore.highScoreCollection] as? String{
                            self.highScore = Int(updatedHighScore)!
                        }
                    }
                }
            }
        }
    }
    
    func updateHighScore() {
        if userScore > highScore {
            db.collection(K.FStore.highScoreCollection).getDocuments { (querySnapshot , error) in
                if let e = error {
                    print("There was an error \(e)")
                } else {
                    let document = querySnapshot!.documents.first
                    document!.reference.updateData([K.FStore.highScoreCollection: "\(self.userScore)"])
                    print("Successfully saved data")
                }
            }
        }
    }

}
