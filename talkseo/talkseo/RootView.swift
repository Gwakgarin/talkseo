import SwiftUI

struct RootView: View {
    let userID: Int
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack { 
            VStack(spacing: 0) {

                ZStack {
                    switch selectedTab {
                    case 0:
                        MainView(userID: userID)
                    case 1:
                        WriteMainView(userID: userID)
                    case 2:
                        CommunityView()
                    case 3:
                        MyPageView()
                    default:
                        MainView(userID: userID)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                BotNav(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    RootView(userID: 1)
}
