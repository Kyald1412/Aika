//
//  MainViewController.swift
//  Aika
//
//  Created by Dhiky Aldwiansyah on 28/04/21.
//

import UIKit

class ResultViewController : UIViewController, UIScrollViewDelegate{
   
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblTimeSpeak: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    
    var expression = Expression()
    
    var slides:[UIView] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTimeSpeak.text = "Time Speaking \(expression.timeSpeaking)"
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [UIView] {

        let slide1:EmotionsResultView = Bundle.main.loadNibNamed("EmotionsResultView", owner: self, options: nil)?.first as! EmotionsResultView
        slide1.setText(expression: expression)
        
        let slide2:SpeechResultView = Bundle.main.loadNibNamed("SpeechResultView", owner: self, options: nil)?.first as! SpeechResultView
        slide2.setText(speechText: expression.speechText)
        
        return [slide1, slide2]
    }
    
    func setupSlideScrollView(slides : [UIView]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
}

