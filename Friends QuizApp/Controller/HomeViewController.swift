
import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var highScoreTitle: UITextView!
    @IBOutlet weak var highScore: UITextView!
    
    let db = Firestore.firestore()
    var highScoreVal: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getHighScore()
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
                            self.highScoreVal = updatedHighScore
                            
                            DispatchQueue.main.async {
                                self.highScore.text = "\(self.highScoreVal)/\(K.numOfQuestions)"
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadQuestions(){
        db.collection(K.FStore.collectionName)
            .addDocument(data: [K.FStore.pictureField: "https://user-images.githubusercontent.com/49269198/169656030-6617dcab-b408-4614-a2b3-d368230c9fbf.jpg",
                                K.FStore.answerField: "option2",
                                K.FStore.option1Field: "The Final One",
                                K.FStore.option2Field: "The Last One",
                                K.FStore.option3Field: "The One with All the Babies",
                                K.FStore.option4Field: "The One with the Soap Opera Party"
            ]) { (error) in
                if let e = error {
                    print("There was an error \(e)")
                } else {
                    print("Successfully saved data")
                }
            }
    }
   
}
