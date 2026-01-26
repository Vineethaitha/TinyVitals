//
//  ChildCardCell.swift
//  ChildProfile
//
//  Created by admin0 on 12/21/25.
//

import UIKit

//import UIKit
//
//class ChildCardCell: UICollectionViewCell {
//
//    @IBOutlet weak var avatarImageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var ageLabel: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
//        avatarImageView.clipsToBounds = true
//    }
//
////    func configure(child: ChildProfile, isAddCell: Bool = false) {
////
////        if isAddCell {
////            nameLabel.text = "Add Child"
////            ageLabel.text = ""
////            avatarImageView.image = UIImage(systemName: "plus")
////            return
////        }
////
////        nameLabel.text = child.name
////        ageLabel.text = child.ageString()
////
////        if let filename = child.photoFilename,
////           let image = loadImageFromDisk(filename: filename) {
////            avatarImageView.image = image
////        } else {
////            avatarImageView.image = UIImage(systemName: "person.fill")
////        }
////    }
//
//    func configure(child: ChildProfile) {
//        nameLabel.text = child.name
//        ageLabel.text = child.ageString()
//
//        if let filename = child.photoFilename,
//           let image = loadImageFromDisk(filename) {
//            avatarImageView.image = image
//        } else {
//            avatarImageView.image = UIImage(systemName: "person.fill")
//        }
//    }
//
//    func configureAsAdd() {
//        nameLabel.text = "Add Child"
//        ageLabel.text = ""
//        avatarImageView.image = UIImage(systemName: "plus")
//    }
//
//    private func loadImageFromDisk(filename: String) -> UIImage? {
//        let url = FileManager.default
//            .urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent(filename)
//
//        return UIImage(contentsOfFile: url.path)
//    }
//}
import UIKit
import Foundation

class ChildCardCell: UICollectionViewCell {

    @IBOutlet weak var avatarShadowView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .clear

        // Shadow container
        avatarShadowView.backgroundColor = .clear
        avatarShadowView.layer.shadowColor = UIColor.black.cgColor
        avatarShadowView.layer.shadowOpacity = 0.18
        avatarShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        avatarShadowView.layer.shadowRadius = 8
        avatarShadowView.layer.masksToBounds = false

        // Image view
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
    }



    override func layoutSubviews() {
        super.layoutSubviews()

        avatarShadowView.layer.cornerRadius = 40
        avatarImageView.layer.cornerRadius = 40
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.image = nil
        avatarImageView.tintColor = nil
        avatarImageView.contentMode = .scaleAspectFill
        nameLabel.text = nil
        ageLabel.text = nil
    }







    // MARK: - Normal Child Cell

    func configure(child: ChildProfile) {
        nameLabel.text = child.name
        ageLabel.text = child.ageString

        avatarImageView.backgroundColor = .white
        avatarImageView.contentMode = .scaleAspectFill

        if let filename = child.photoFilename,
           let image = loadImageFromDisk(filename) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }

        avatarImageView.tintColor = nil
    }





    // MARK: - Add Child Cell

    func configureAsAdd() {
        nameLabel.text = "Add Child"
        ageLabel.text = ""

        let config = UIImage.SymbolConfiguration(
            pointSize: 22,
            weight: .medium
        )

        avatarImageView.image = UIImage(
            systemName: "plus",
            withConfiguration: config
        )

        avatarImageView.tintColor = .black
        avatarImageView.contentMode = .center
        contentView.backgroundColor = .clear
    }




    // MARK: - Helpers

    private func loadImageFromDisk(_ filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }
}


//extension ChildProfile {
//
//    func ageString() -> String {
//        let calendar = Calendar.current
//        let components = calendar.dateComponents(
//            [.year, .month],
//            from: dob,
//            to: Date()
//        )
//
//        let years = components.year ?? 0
//        let months = components.month ?? 0
//
//        if years == 0 {
//            return "\(months) month\(months == 1 ? "" : "s")"
//        } else {
//            return "\(years) yr \(months) mo"
//        }
//    }
//}
