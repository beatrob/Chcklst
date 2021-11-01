//
//  TypeAliases.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine

typealias ChecklistPassthroughSubject = PassthroughSubject<ChecklistDataModel, Never>
typealias ChecklistCurrentValueSubject = CurrentValueSubject<ChecklistDataModel?, Never>
typealias ChecklistPublisher = AnyPublisher<ChecklistDataModel, Never>

typealias ChecklistItemPassthroughSubject = PassthroughSubject<ItemDataModel, Never>

typealias TemplatePassthroughSubject = PassthroughSubject<TemplateDataModel, Never>
typealias TemplateCurrentValueSubject = CurrentValueSubject<TemplateDataModel?, Never>

typealias FilterPassthroughSubject = PassthroughSubject<SortDataModel, Never>

typealias EmptySubject = PassthroughSubject<Void, Never>
typealias EmptyCompletion = () -> Void
typealias EmptyPublisher = AnyPublisher<Void, Never>
