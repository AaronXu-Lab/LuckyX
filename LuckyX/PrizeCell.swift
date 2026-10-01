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

    func loadImage(url: String) {
        imageTask?.cancel()
        representedURL = url
        prizeImageView.contentMode = .scaleToFill
        prizeImageView.image = UIImage(named: "OPPO")
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
