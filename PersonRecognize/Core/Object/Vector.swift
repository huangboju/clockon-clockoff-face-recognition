//
//  Vector.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 22/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//


import Foundation
//import KDTree


struct Vector {
    var name: String
    var vector: [Double]
    var distance: Double
    
}

extension Vector {
    init(name: String, vector: [Double]) {
        self.init(name: name,
                  vector: vector,
                  distance: 0)
    }
    
    init?(item: [String: Any]) {
        guard let name = item["name"] as? String,
              let vector = item["vector"] as? [Double],
              let distance = item["distance"] as? Double
        else {
            print("Error at get vectors")
            return nil
        }
        self.name = name
        self.vector = vector
        self.distance = distance
    }
    
    var dict: [String: Any] {
        return [
            "name": name,
            "vector": vector,
            "distance": distance
        ]
    }
}
extension Sequence where Iterator.Element: Hashable {
    func uniq() -> [Iterator.Element] {
        var seen = Set<Iterator.Element>()
        return filter { seen.update(with: $0) == nil }
    }
}

extension Vector : Hashable {
    //var hash : [Double] { return self.vector }
}

func == (lhs: Vector, rhs: Vector) -> Bool {
    return lhs.vector == rhs.vector
}

