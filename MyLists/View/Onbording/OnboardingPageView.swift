//
//  OnboardingPageView.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 11/10/2024.
//

import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let image: Image?
    let text: String
    var isFirstPage: Bool = false
    var isLastPage: Bool = false
    
    init(title: String, image: Image?, text: String, isFirstPage: Bool = false, isLastPage: Bool = false) {
        self.title = title
        self.image = image
        self.text = text
        self.isFirstPage = isFirstPage
        self.isLastPage = isLastPage
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Text(title)
                            .font(.title2)
                        
                        HStack {
                            if !isFirstPage {
                                Image.backward.sizedToFit(height: 16)
                            }
                            
                            Spacer()
                            
                            if !isLastPage {
                                Image
                                    .forward
                                    .sizedToFit(height: 16)
                            }
                        }
                        .foregroundStyle(Color.cyan)
//                        if !isFirstPage {
//                            HStack {
//                                Image.backward
//                                    .sizedToFit(height: 16)
//                                    
//                                Spacer()
//                            }
//                            .foregroundStyle(Color.cyan.opacity(0.5))
//                        }
//                        
//                        if !isLastPage {
//                            HStack {
//                                Spacer()
//
//                                Image
//                                    .forward
//                                    .sizedToFit(height: 16)
//                                    
//                            }
//                            .foregroundStyle(Color.cyan.opacity(0.5))
//                        }
                    }
                    
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 520)
                        
                    }
                    
                    Text(text)
                        .font(.title2.weight(.light))
                    
                    Spacer()
                }
                .foregroundStyle(Color.primary)
                .padding()
            }
            .scrollIndicators(.hidden)
        }
        
    }
}

// MARK: - Navigation indicators

extension OnboardingPageView {
    @inlinable mutating func asFirstPage() -> Self {
        isFirstPage = true
        return self
    }
    
    @inlinable mutating func asLastPage() -> Self {
        isLastPage = true
        return self
    }
}

// MARK: - Onboarding Pages

extension OnboardingPageView {
    
    static var welcomeTextPageView: OnboardingPageView {
        OnboardingPageView(
            title: "Hi there!",
            image: nil,
            text:
"""
We’re thrilled that you’ve downloaded our app!

As a first-time user, we will guide you on how to make the most of its features during this onboarding process.

Don’t worry about forgetting anything; you can always review these instructions in the "About" tab.
""",
            isFirstPage: true
        )
    }
    
    static var toDoLists: OnboardingPageView {
        OnboardingPageView(
            title: "Lists:",
            image: Image("1.OverviewLists"),
            text: "This is the starting page of our app, displaying all your lists."
        )
    }
    
    static var addToDoListsButton: OnboardingPageView {
        OnboardingPageView(
            title: "Add a list:",
            image: Image("2.OverviewNewList"),
            text: "To add a new list, press the plus button indicated by the red arrow."
        )
    }
    
    static var addToDoListsFields: OnboardingPageView {
        OnboardingPageView(
            title: "New list fields:",
            image: Image("3.OverviewNewListDetails"),
            text:
"""
A list has two basic fields: Name and Details. The Name is mandatory and must be unique, while Details is optional \
and may be left empty.
"""
        )
    }
    
    static var addNewToDoItems: OnboardingPageView {
        OnboardingPageView(
            title: "New list items:",
            image: Image("4.OverviewNewListItem"),
            text:
"""
Once a list is created, select it to view a screen displaying its name and details. To add items, simply press the \
'＋' icon on the top right corner of the list view.

In the add items view (as seen in the screenshot above), you can add one or more items in the same screen. The bottom right "+" is used to add more than one items. Once you have all the items you need, just press "Save". 
"""
        )
    }
    
    static var listItems: OnboardingPageView {
        OnboardingPageView(
            title: "List items:",
            image: Image("5.OverviewMarkItemsAsDone"),
            text: "Now your list contains items that can be toggled between ☑ (done) and ☐ (todo) by tapping on them."
        )
    }
    
    static var sortlistItems: OnboardingPageView {
        OnboardingPageView(
            title: "Sorting list items:",
            image: Image("6.OverviewAlphabetically"),
            text: "You can also sort a list’s items either alphabetically or by their completion status."
        )
    }
    
    static var listsCompletion: OnboardingPageView {
        OnboardingPageView(
            title: "Lists completion:",
            image: Image("7.OverviewListCompletion"),
            text: 
"""
As you mark list items as ☑ (done), the Lists screen updates each list’s completion gauge to reflect the percentage \
of items completed.
"""
        )
    }
    
    static var blueprints: OnboardingPageView {
        OnboardingPageView(
            title: "Blueprints:",
            image: Image("8.OverviewBlueprints"),
            text: 
"""
Blueprints are models of lists. You create them in the same way as you do with regular lists. Their purpose is to \
store templates for lists you use regularly, such as a chores list or a travel checklist. Whenever you need one of \
these lists, you can simply create a copy from its corresponding Blueprint.
"""
        )
    }
    
    static var blueprintAddListInstance: OnboardingPageView {
        OnboardingPageView(
            title: "More about blueprints:",
            image: Image("9.OverviewCreateListFromBlueprint"),
            text: 
"""
Like lists, blueprints have names, details (optional), and items, but they are distinct entities.

For example, you’ll notice that an item in a blueprint cannot be marked as 'done' or 'todo.' Blueprints exist solely \
to store information such as the name, details, and items, and they serve as templates for creating actual lists, \
complete with checkmarks. As mentioned earlier, the idea is to facilitate the recreation of checklists you use \
frequently.

Once you’ve completed a list and marked all items as done, you can safely delete it, knowing that you can always \
recreate it from its corresponding blueprint when the need arises.

To create a new list from a blueprint, simply press the 'Create List' button, indicated by the red arrow, and a \
corresponding list will be automatically generated in the 'Lists' tab.

Please note that a blueprint cannot be used to create a second list if another list already exists that was generated \
from that blueprint, as all lists must have unique names. The 'Create List' button — again indicated by the red arrow \
— will only be visible if there is no current list created from the blueprint in question.   
"""
        )
    }
    
    static var blueprintsInstanceList: OnboardingPageView {
        OnboardingPageView(
            title: "List from blueprint:",
            image: Image("10.OverviewBlueprintInstance"),
            text: 
"""
Here we have a brand-new Business Trip checklist to help ensure you don’t forget anything important before boarding \
your flight. Meanwhile the corresponding Blueprint remains there to recreate a "Business Trip" checklist whenever \
it's needed again.
"""
        )
    }
    
    static var entityUpdate: OnboardingPageView {
        OnboardingPageView(
            title: "Editing Lists and Blueprints",
            image: Image("11.OverviewUpdate"),
            text:
"""
You can modify the names and details of both lists and blueprints. Simply press the designated button, \
and you will be directed to the same interface used for creating them, but this time you’ll be editing an existing \
list or blueprint.
""",
            isLastPage: true
        )
    }
    
    static var shareList: OnboardingPageView {
        OnboardingPageView(
            title: "Sharing lists as text",
            image: Image("12.ShareYourListInTextFormat"),
            text:
"""
Lastly, you can share your checklists in text format, making it possible to not only send them to a friend, but to print them!
""",
            isLastPage: true
        )
    }
    
}

#Preview {
    NavigationStack {
        OnboardingPageView.blueprintsInstanceList
    }
    
}
