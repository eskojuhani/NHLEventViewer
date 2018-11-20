//
//  BeerStyles.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 15/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Foundation

struct BeerStyles : Codable {
    struct BeerStyleKey : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let description = BeerStyleKey(stringValue: "description")!
    }
    
    struct BeerStyle : Codable {
        let name: String
        let description: String
    }
    
    let beerStyles : [BeerStyle]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BeerStyleKey.self)
        
        var styles: [BeerStyle] = []
        for key in container.allKeys {
            let nested = try container.nestedContainer(keyedBy: BeerStyleKey.self,
                                                       forKey: key)
            let description = try nested.decode(String.self,
                                                forKey: .description)
            styles.append(BeerStyle(name: key.stringValue,
                                    description: description))
        }
        
        self.beerStyles = styles
    }
}

