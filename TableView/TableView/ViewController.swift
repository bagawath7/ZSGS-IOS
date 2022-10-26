//
//  ViewController.swift
//  TableView
//
//  Created by zs-mac-4 on 27/09/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var button4: UIButton!
    var colors = [UIColor.systemRed, UIColor.systemBlue, UIColor.systemOrange,
                  UIColor.systemPurple,UIColor.systemGreen]
    var tableViewHeaderText = ""
    
    /// an enum of type TableAnimation - determines the animation to be applied to the tableViewCells
    var currentTableAnimation: TableAnimation = .fadeIn(duration: 0.85, delay: 0.03) {
        didSet {
            self.tableViewHeaderText = currentTableAnimation.getTitle()
        }
    }
    var animationDuration: TimeInterval = 0.85
    var delay: TimeInterval = 0.05
    var fontSize: CGFloat = 26
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonStyle()
        self.colors.append(contentsOf: colors.shuffled())
                
                // registering the tableView
                self.tableView.register(UINib(nibName: TableAnimationViewCell.description(), bundle: nil),
                forCellReuseIdentifier: TableAnimationViewCell.description())
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.isHidden = true
                
                // set the separatorStyle to none and set the Title for the tableView
                self.tableView.separatorStyle = .none
                self.tableViewHeaderText = self.currentTableAnimation.getTitle()
                
                // set the button1 as selected and reload the data of the tableView to see the animation
                Button1.setImage(UIImage(systemName: "1.circle.fill", withConfiguration:
                UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold, scale: .large)), for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
        // Do any additional setup after loading the view.
    }
    private func buttonStyle(){
        Button1.tag = 1
        Button2.tag = 2
        Button3.tag = 3
        button4.tag = 4
    }

    @IBAction func animatedButtonPressed(_ sender: Any) {
        guard let senderButton = sender as? UIButton else { return }
               
               /// set the buttons symbol to the default unselected circle
               Button1.setImage(UIImage(systemName: "1.circle", withConfiguration:
                                        UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold, scale: .large)),
                                for: .normal)
               Button2.setImage(UIImage(systemName: "2.circle", withConfiguration:
                                        UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold, scale: .large)),
                                for: .normal)
               Button3.setImage(UIImage(systemName: "3.circle", withConfiguration:
                                        UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold, scale: .large)),
                                for: .normal)
               button4.setImage(UIImage(systemName: "4.circle", withConfiguration:
                                        UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold, scale: .large)),
                                for: .normal)
               
               /// based on the tag of the button, set the symbol of the associated button to show it's selected and set the currentTableAnimation.
               switch senderButton.tag {
               case 1: senderButton.setImage(UIImage(systemName: "1.circle.fill", withConfiguration:
                                                     UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold,
                                                                                 scale: .large)), for: .normal)
               currentTableAnimation = TableAnimation.fadeIn(duration: animationDuration, delay: delay)
               case 2: senderButton.setImage(UIImage(systemName: "2.circle.fill", withConfiguration:
                                                     UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold,
                                                                                 scale: .large)), for: .normal)
               currentTableAnimation = TableAnimation.moveUp(rowHeight: TableAnimationViewCell().tableViewHeight,
                                                             duration: animationDuration, delay: delay)
               case 3: senderButton.setImage(UIImage(systemName: "3.circle.fill", withConfiguration:
                                                     UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold,
                                                                                 scale: .large)), for: .normal)
               currentTableAnimation = TableAnimation.moveUpWithFade(rowHeight: TableAnimationViewCell().tableViewHeight,
                                                                     duration: animationDuration, delay: delay)
               case 4: senderButton.setImage(UIImage(systemName: "4.circle.fill", withConfiguration:
                                                     UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold,
                                                                                 scale: .large)), for: .normal)
               currentTableAnimation = TableAnimation.moveUpBounce(rowHeight: TableAnimationViewCell().tableViewHeight,
                                                                   duration: animationDuration + 0.2, delay: delay)
               default: break
               }
               
               /// reloading the tableView to see the animation
               self.tableView.reloadData()
           }
        
    }


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableAnimationViewCell().tableViewHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TableAnimationViewCell.description(),
                                                    for: indexPath) as? TableAnimationViewCell {
            // set the color of the cell
            cell.color = colors[indexPath.row]
            return cell
        }
        fatalError()
    }
    
    // for displaying the headerTitle for the tableView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 42))
        headerView.backgroundColor = UIColor.systemBackground
        
        let label = UILabel()
        label.frame = CGRect(x: 24, y: 12, width: self.view.frame.width, height: 42)
        label.text = tableViewHeaderText
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    
    //
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // fetch the animation from the TableAnimation enum and initialze the TableViewAnimator class
        let animation = currentTableAnimation.getAnimation()
        let animator = TableViewAnimator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
}
