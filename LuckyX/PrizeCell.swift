//
//  PrizeCell.swift
//  LuckyX
//
//  Created by 徐炜楠 on 2018/11/18.
//  Copyright © 2018 徐炜楠. All rights reserved.
//

import UIKit

class PrizeCell: UICollectionViewCell {
    @IBOutlet var prizeImageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var selectMask: UIImageView!
    private var imageTask: URLSessionDataTask?
    private var representedURL: String?

    func loadImage(url: String, prizeName: String) {
        imageTask?.cancel()
        representedURL = url
        prizeImageView.contentMode = .scaleAspectFit
        prizeImageView.backgroundColor = .white
        prizeImageView.tintColor = .systemPink
        let symbol: String
        if prizeName.contains("红包") { symbol = "envelope.fill" }
        else if prizeName.contains("购物卡") { symbol = "creditcard.fill" }
        else if prizeName.contains("耳机") { symbol = "headphones" }
        else if prizeName.contains("键盘") { symbol = "keyboard" }
        else if prizeName.contains("行李箱") { symbol = "suitcase.rolling.fill" }
        else { symbol = "gift.fill" }
        prizeImageView.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 36))?.withAlignmentRectInsets(UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16))
        guard let imageURL = URL(string: url) else { return }
        var request = URLRequest(url: imageURL)
        request.timeoutInterval = 10
        imageTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
                  let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard self?.representedURL == url else { return }
                self?.prizeImageView.image = image
            }
        }
        imageTask?.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        representedURL = nil
        prizeImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        prizeImageView.layer.cornerRadius = 12
    }
    
}
