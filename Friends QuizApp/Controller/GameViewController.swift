
import UIKit
import FirebaseFirestore

class GameViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var option1: UIButton!
    @IBOutlet weak var option2: UIButton!
    @IBOutlet weak var option3: UIButton!
    @IBOutlet weak var option4: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var heart3: UIImageView!
    @IBOutlet weak var heart2: UIImageView!
    @IBOutlet weak var heart1: UIImageView!
    @IBOutlet weak var questionProgress: UITextView!
    
    let db = Firestore.firestore()
    var gameManager = GameManager()
    var optionChosen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        progressBar.progress = 0.0
        loadQuestions()
    }
    
    @IBAction func optionClicked(_ sender: UIButton) {
        //Check if the answer selected is correct
        if !optionChosen {
            optionChosen = true
            
            sender.tintColor = UIColor(named: K.Colors.yellow)
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                //Check answer and change color of buttons accordingly
                if let userAnswer = sender.titleLabel?.text {
                    //If the user's answer is incorecct - change color to red and subtract 1 heart
                    if !self.gameManager.checkAnswer(userAnswer: userAnswer) {
                        self.changeHearts()
                        sender.tintColor = UIColor(named: K.Colors.red)
                    }
                    self.colorCorrectAnswer()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if !self.gameManager.gameOver {
                    self.updateQuestionView()
                } else {
                    //result screen
                    self.performSegue(withIdentifier: K.gameSegue, sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.gameSegue {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.userScore = gameManager.score
        }
    }
    
    func colorCorrectAnswer(){
        if option1.titleLabel?.text == gameManager.currentQuestion?.answer {
            option1.tintColor = UIColor(named: K.Colors.green)
        } else if option2.titleLabel?.text == gameManager.currentQuestion?.answer {
            option2.tintColor = UIColor(named: K.Colors.green)
        } else if option3.titleLabel?.text == gameManager.currentQuestion?.answer {
            option3.tintColor = UIColor(named: K.Colors.green)
        } else if option4.titleLabel?.text == gameManager.currentQuestion?.answer {
            option4.tintColor = UIColor(named: K.Colors.green)
        }
    }
    
    func changeHearts(){
        if gameManager.lives == 3 {
            heart3.image = UIImage(named: K.Hearts.heart)!
            heart2.image = UIImage(named: K.Hearts.heart)!
            heart1.image = UIImage(named: K.Hearts.heart)!
        } else if gameManager.lives == 2 {
            heart1.image = UIImage(named: K.Hearts.emptyHeart)!
        } else if gameManager.lives == 1 {
            heart2.image = UIImage(named: K.Hearts.emptyHeart)!
        } else if gameManager.lives == 0 {
            heart3.image = UIImage(named: K.Hearts.emptyHeart)!
        }
    }
    
    
    func resetButtons(){
        optionChosen = false
        option1.tintColor = UIColor(named: K.Colors.blue)
        option2.tintColor = UIColor(named: K.Colors.blue)
        option3.tintColor = UIColor(named: K.Colors.blue)
        option4.tintColor = UIColor(named: K.Colors.blue)
    }
    
    
    func updateQuestionView (){
        gameManager.getNextQuestion()
        resetButtons()
        questionProgress.text = "\(gameManager.questionCounter)/\(K.numOfQuestions)"
        progressBar.progress =  Float(gameManager.questionCounter) / Float(K.numOfQuestions)
        
        if let picture = gameManager.currentQuestion?.picture {
            if let imageUrl = URL(string:picture) {
                imageView.imageFrom(url: imageUrl)
            }
        }

        option1.setTitle(gameManager.currentQuestion?.option1, for: .normal)
        option1.titleLabel?.adjustsFontSizeToFitWidth = true
        option1.titleLabel?.numberOfLines = 0
     
        option2.setTitle(gameManager.currentQuestion?.option2, for: .normal)
        option2.titleLabel?.adjustsFontSizeToFitWidth = true
        option2.titleLabel?.numberOfLines = 0
   
        option3.setTitle(gameManager.currentQuestion?.option3, for: .normal)
        option3.titleLabel?.adjustsFontSizeToFitWidth = true
        option3.titleLabel?.numberOfLines = 0
        
        option4.setTitle(gameManager.currentQuestion?.option4, for: .normal)
        option4.titleLabel?.adjustsFontSizeToFitWidth = true
        option4.titleLabel?.numberOfLines = 0
       
    }

    func loadQuestions(){
        db.collection(K.FStore.collectionName)
            .addSnapshotListener { [self] querySnapshot, error in
            
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let questionPicture = data[K.FStore.pictureField] as? String ,
                           let questionAnswer = data[K.FStore.answerField] as? String ,
                           let questionOption1 = data[K.FStore.option1Field] as? String,
                           let questionOption2 = data[K.FStore.option2Field] as? String,
                           let questionOption3 = data[K.FStore.option3Field] as? String,
                           let questionOption4 = data[K.FStore.option4Field] as? String
                            
                        {
                            let newQuestion = Question(picture: questionPicture, answer: questionAnswer, option1: questionOption1, option2: questionOption2, option3: questionOption3, option4: questionOption4)
                            self.gameManager.questions.append(newQuestion)
                        }
                    }
                    DispatchQueue.main.async{
                        self.updateQuestionView()
                    }
                }
                
            }
        }
    }

}

//MARK: - Extension for loading URL to ImageView
extension UIImageView{
    func imageFrom(url:URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data:data){
                    DispatchQueue.main.async{
                        self?.image = image
                    }
                }
            }
        }
    }
}


