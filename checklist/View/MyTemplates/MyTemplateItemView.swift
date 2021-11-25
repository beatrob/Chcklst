//
//  MyTemplatesItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MyTemplateItemView: View {
    
    let name: String
    let description: String?
    let displayRightArrow: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing:0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(name)
                        .modifier(Modifier.Template.SmallTitle())
                        .foregroundColor(.firstAccent)
                        .padding(.top)
                    if let description = description, !description.isEmpty {
                        Text(description)
                            .modifier(Modifier.Checklist.Description())
                            .lineLimit(3)
                            .padding(.vertical)
                    }
                }
                if displayRightArrow {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .modifier(Modifier.Template.SmallTitle())
                }
            }
            .padding(.horizontal)
            SeparatorView()
        }
    }
}

struct MyTemplateItemView_Previews: PreviewProvider {
    static var previews: some View {
        MyTemplateItemView(
            name: "My first template",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Non diam phasellus vestibulum lorem sed risus. Tristique senectus et netus et. Orci eu lobortis elementum nibh tellus molestie. Tincidunt arcu non sodales neque sodales ut etiam. Tellus pellentesque eu tincidunt tortor. Nunc pulvinar sapien et ligula ullamcorper malesuada proin. Risus nullam eget felis eget nunc lobortis. Aliquam ut porttitor leo a diam sollicitudin tempor id. At consectetur lorem donec massa sapien faucibus et molestie ac. Adipiscing elit ut aliquam purus sit. Euismod lacinia at quis risus sed. Ut tortor pretium viverra suspendisse potenti. Purus viverra accumsan in nisl nisi. Ac turpis egestas sed tempus urna et pharetra. Eget duis at tellus at urna condimentum mattis pellentesque id. Commodo viverra maecenas accumsan lacus. Massa ultricies mi quis hendrerit dolor magna eget est. Suspendisse interdum consectetur libero id faucibus nisl tincidunt eget.",
            displayRightArrow: true
        ).previewLayout(.sizeThatFits)
    }
}
