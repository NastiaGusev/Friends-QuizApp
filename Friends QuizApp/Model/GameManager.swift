
import Foundation

struct GameManager {
    var questions :[Question] = []
    var questionCounter : Int = 0
    var currentQuestion : Question?
    var gameOver : Bool = false
    var lives = 3
    var score = 0
    
    mutating func getNextQuestion(){
        if !questions.isEmpty {
            currentQuestion = questions[0]
            questions.remove(at: 0)
            questionCounter += 1
        } else {
            gameOver = true
        }
        if questions.count == 0 {
            gameOver = true
        }
    }
    
    mutating func checkAnswer(userAnswer : String) -> Bool {
        var answer = false
        if userAnswer == currentQuestion?.answer {
            score += 1
            answer = true
        } else {
            lives -= 1
            answer = false
        }
        if lives == 0 {
            gameOver = true
        }
        return answer
    }
    
    
}
