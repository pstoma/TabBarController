//
//  FacebookTabBar.swift
//  TabBarController_Example
//
//  Created by Arnaud Dorgans on 16/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TabBarController

class FacebookTabBarItem: UITabBarItem {
    
    @IBInspectable var selectedTintColor: UIColor = .cyan
}

@IBDesignable class FacebookTabBar: UIView, TabBarProtocol {
    
    private let contentView = UIStackView()
    
    weak var delegate: TabBarDelegate?

    var items: [UITabBarItem]?
    var selectedItem: UITabBarItem? {
        didSet {
            updateSelectedItem()
        }
    }
    
    @IBInspectable var unselectedItemTintColor: UIColor = .gray {
        didSet {
            updateSelectedItem()
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return contentView.arrangedSubviews.sorted(by: { lhs, _ in return (lhs as? UIButton)?.isSelected == true })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
    }
    
    private func sharedInit() {
        self.backgroundColor = .white
        
        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        if #available(iOS 11.0, *) {
            contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    }
    
    func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        self.items = items
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let items = items else {
            return
        }
        items.forEach {
            guard let button = FacebookTabBarButton(item: $0) else {
                return
            }
            button.addTarget(self, action: #selector(self.didSelect(_:)), for: .touchUpInside)
            contentView.addArrangedSubview(button)
        }
        updateSelectedItem()
    }
    
    private func updateSelectedItem() {
        contentView.arrangedSubviews.forEach {
            guard let button = $0 as? FacebookTabBarButton else {
                return
            }
            button.isSelected = button.item == self.selectedItem
        }
    }
    
    @objc func didSelect(_ button: UIButton) {
        guard let button = button as? FacebookTabBarButton else {
            return
        }
        self.delegate?.tabBar(self, didSelect: button.item)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let nextButton = context.nextFocusedView as? FacebookTabBarButton else {
            return
        }
        self.didSelect(nextButton)
    }
    
    override func prepareForInterfaceBuilder() {
        let item: (String, String)->UITabBarItem = {
            return UITabBarItem(title: nil,
                                image: UIImage(named: $0, in: Bundle(for: FacebookTabBar.self), compatibleWith: nil),
                                selectedImage: UIImage(named: $1, in: Bundle(for: FacebookTabBar.self), compatibleWith: nil))
        }
        let items = [item("outline-chrome_reader_mode-24px", "twotone-chrome_reader_mode-24px"),
                     item("outline-account_circle-24px", "twotone-account_circle-24px"),
                     item("outline-notifications-24px", "twotone-notifications-24px")]
        self.setItems(items, animated: false)
        self.selectedItem = items.first
    }
}

private class FacebookTabBarButton: UIButton {
    
    let item: FacebookTabBarItem
    
    override var isSelected: Bool {
        didSet {
            update()
        }
    }
    
    init?(item: UITabBarItem) {
        guard let item = item as? FacebookTabBarItem else {
            return nil
        }
        self.item = item
        super.init(frame: .zero)
        update()
    }
    
    private func update() {
        self.setImage(self.isSelected ? item.selectedImage : item.image, for: .normal)
        self.tintColor = self.isSelected ? item.selectedTintColor : .black
        self.transform = self.isFocused ? CGAffineTransform(scaleX: 1.5, y: 1.5) : .identity
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations(self.update, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}