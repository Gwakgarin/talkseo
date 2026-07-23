import SwiftUI

struct MyPageView: View {
    @State private var nickname: String = ""
    @State private var email: String = ""
    @State private var readBooks: [ReadBookItem] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                //상단바
                HStack {
                    Spacer()
                    Text("마이페이지")
                        .font(.headline)
                    Spacer()
                }
                .padding(.vertical, 12)

                
                // 프로필
                VStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Text(nickname)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("프로필 편집 >") {}
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
                .padding(.vertical, 20)

                // 읽은 책 타이틀
                HStack {
                    Text("읽은 책")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // 읽은 책 리스트
                VStack(spacing: 12) {
                    ForEach(readBooks) { item in
                        ReadBookRow(book: item)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear { loadMyPageData() }
    }
    
    
    // 서버 데이터 로드
    @MainActor
    func loadMyPageData() {
        let userID = UserDefaults.standard.integer(forKey: "loginUserID")
        guard userID > 0 else { return }
        
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/my_page.php?user_id=\(userID)") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(MyPageResponse.self, from: data)
                
                nickname = decoded.nickname
                email = decoded.email
                readBooks = decoded.books
                
            } catch {
                print("MyPage Error:", error)
            }
        }
    }
}


// 서버 응답 모델
struct MyPageResponse: Codable {
    let nickname: String
    let email: String
    let books: [ReadBookItem]
}


// 읽은 책 모델
struct ReadBookItem: Identifiable, Codable {
    var id: String { user_book_id }
    let user_book_id: String
    let title: String
    let author: String
    let cover: String
}


// 읽은 책 Row
struct ReadBookRow: View {
    let book: ReadBookItem
    
    var body: some View {
        HStack(spacing: 12) {
            
            AsyncImage(url: URL(string: book.cover)) { img in
                img.resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 80)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title).font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

#Preview {
    MyPageView()
}
