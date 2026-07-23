import SwiftUI

struct CompletedBookDetailView: View {
    let userID: Int
    let userBookID: Int
    let bookTitle: String

    @State private var selectedTab = 0
    @State private var review: ReviewItem? = nil

    var body: some View {
        VStack(spacing: 0) {


            HStack {
                tabButton(title: "타이머", index: 0)
                tabButton(title: "감상평", index: 1)
            }
            .padding(.top, 10)

            Divider()


            if selectedTab == 0 {
                // 타이머 탭
                SelectBookView(userBookID: userBookID)
            } else {
                // 감상평 탭
                reviewSection
            }
        }
        .navigationTitle(bookTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadReview()
        }
    }

    private var reviewSection: some View {
        Group {
            if let review = review,
               let content = review.content,
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

       
                WriteReviewMainView(
                    review: review,
                    bookTitle: bookTitle
                )

            } else {
   
                VStack {
                    Spacer()

                    Text("작성한 감상평이 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.bottom, 24)

                    NavigationLink {
                        BookWriteView(
                            userBookId: String(userBookID),
                            title: bookTitle,
                            initialReview: nil,
                            reviewComplete: {
                                loadReview()
                            }
                        )
                    } label: {
                        Text("기록하기")
                            .fontWeight(.bold)
                            .frame(width: 120, height: 44)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(22)
                    }

                    Spacer()
                }
            }
        }
    }





    private func tabButton(title: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(selectedTab == index ? .black : .gray)
                Rectangle()
                    .fill(selectedTab == index ? .green : .clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }


    func loadReview() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/get_review.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "user_id=\(userID)&user_book_id=\(userBookID)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }

            if let decoded = try? JSONDecoder().decode(ReviewResponse.self, from: data),
               decoded.success {

                let item = ReviewItem(
                    user_book_id: decoded.user_book_id,
                    start_date: decoded.start_date,
                    end_date: decoded.end_date,
                    content: decoded.content,
                    visibility: decoded.visibility,
                    is_spoiler: decoded.is_spoiler
                )

                DispatchQueue.main.async {
                    review = item
                }
            } else {
                DispatchQueue.main.async {
                    review = nil
                }
            }
        }.resume()
    }
}


struct ReviewItem: Codable {
    let user_book_id: String?
    let start_date: String?
    let end_date: String?
    let content: String?
    let visibility: String?
    let is_spoiler: String?
}

struct ReviewResponse: Codable {
    let success: Bool
    let message: String?
    let user_book_id: String?
    let start_date: String?
    let end_date: String?
    let content: String?
    let visibility: String?
    let is_spoiler: String?
}
