//
//  DebugCellView.swift
//  checklist
//
//  Created by Robert Konczi on 11/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DebugCellView: View {
    
    @ObservedObject var viewModel: DebugCellViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .modifier(Modifier.Checklist.BigTitle())
                .padding(.bottom)
            ForEach(viewModel.attributes.keys, id: \.self) { key in
                VStack(alignment: .leading) {
                    Text(key)
                        .modifier(Modifier.Checklist.SmallTitle(color: .text))
                    Text(viewModel.attributes[key] ?? "")
                        .modifier(Modifier.Checklist.Description())
                        .padding(.bottom)
                }
            }
            SeparatorView()
        }.padding()
    }
}

struct DebugCellView_Previews: PreviewProvider {
    static var previews: some View {
        DebugCellView(
            viewModel: .init(
                id: "1234",
                title: "Some debug stuff",
                attributes: [
                    "attr1" : "asdas d ahsd ajbhsd jhabs djhab sjhdba jsd",
                    "attr2" : "hs dfjnk sjdnfjhs dkjhab sdjcblsd cakjhrf kjhbdjvzbdfjkv zx",
                    "attr3" : "hjsdb fkjabdhs fkjabh sdkhfba sjkdhbcajsbdh chsdeliachuw fvhjmszbdv"
                ]
            )
        ).previewLayout(.sizeThatFits)
    }
}
