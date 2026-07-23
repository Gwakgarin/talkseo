import SwiftUI

// MARK: - 모델

struct BookDetail: Codable {
    let book_id: String
    let title: String
    let cover_image_url: String?
    let author: String?
    let publisher: String?
    let summary: String?
    let total_pages: String?
    let isbn: String?
}

struct ReviewListItem: Codable, Identifiable {
    var id: String { review_id }
    let review_id: String
    let content: String
    let likes_count: String?
    let update_date: String?
    let start_date: String?
    let end_date: String?
    let nickname: String?
}

struct AddBookResponse: Codable {
    let status: String
    let user_book_id: String?
}

// review_list.php 응답
struct ReviewListResponse: Codable {
    let success: Bool
    let reviews: [ReviewListItem]
}

// MARK: - 도서 상세 뷰

struct SearchDetailView: View {
    let userID : Int
    let book_id: String
   

    @State private var bookDetail: BookDetail?
    @State private var selectedTab: Int = 0
    @State private var reviewList: [ReviewListItem] = []
    @State private var goToMain = false

    var body: some View {
        VStack {
            NavigationLink(
                destination: MainView(userID: userID),
                isActive: $goToMain
            ) { EmptyView() }

            .hidden()

            ScrollView {
                if let book = bookDetail {
                    VStack(alignment: .leading, spacing: 16) {

                        // 표지
                        if let cover = book.cover_image_url,
                           let url = URL(string: cover) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFit()
                                } else if phase.error != nil {
                                    Color.gray.opacity(0.2)
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(height: 250)
                        }

                        // 기본 정보
                        Text(book.title)
                            .font(.title)
                            .bold()

                        Text("작가: \(book.author ?? "-")")
                        Text("출판사: \(book.publisher ?? "-")")

                        // 탭
                        HStack(spacing: 0) {
                            Button {
                                selectedTab = 0
                            } label: {
                                VStack {
                                    Text("책 정보")
                                        .foregroundColor(selectedTab == 0 ? .black : .gray)
                                    Rectangle()
                                        .fill(selectedTab == 0 ? .green : .clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Button {
                                selectedTab = 1
                                // ✅ 감상평 탭으로 처음 들어올 때 리스트 로딩
                                if reviewList.isEmpty {
                                    fetchReviewList()
                                }
                            } label: {
                                VStack {
                                    Text("감상평")
                                        .foregroundColor(selectedTab == 1 ? .black : .gray)
                                    Rectangle()
                                        .fill(selectedTab == 1 ? .green : .clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 20)

                        Divider()

                        // 탭 내용
                        if selectedTab == 0 {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("책 소개")
                                    .font(.headline)
                                Text(book.summary ?? "소개 없음")
                                Divider()
                                Text("전체 페이지수: \(book.total_pages ?? "-")")
                                Text("ISBN: \(book.isbn ?? "-")")
                            }
                        } else {
                            ReviewListView(reviewList: $reviewList)
                                .onAppear {
                                    // 스크롤해서 들어올 때도 한 번 더 안전하게
                                    if reviewList.isEmpty {
                                        fetchReviewList()
                                    }
                                }
                        }
                    }
                    .padding()

                } else {
                    // 첫 진입 시 책 + 리뷰 같이 로딩
                    ProgressView("불러오는 중...")
                        .onAppear {
                            fetchBookDetail()
                            fetchReviewList()
                        }
                }
            }
        }
        .navigationTitle("도서 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                addBookToUserList()
            } label: {
                Text("추가하기")
                    .foregroundColor(.green)
            }
        }
    }

    // MARK: - 네트워크

    func fetchBookDetail() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/book_detail.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "book_id=\(book_id)".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }

            if let decoded = try? JSONDecoder().decode(BookDetail.self, from: data) {
                DispatchQueue.main.async {
                    bookDetail = decoded
                }
            } else {
                print("book_detail decode fail:", String(decoding: data, as: UTF8.self))
            }
        }.resume()
    }

    func fetchReviewList() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/review_list.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "book_id=\(book_id)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }

            // 🔍 서버 응답 확인용
            let raw = String(decoding: data, as: UTF8.self)
            print("review_list raw:", raw)

            if let decoded = try? JSONDecoder().decode(ReviewListResponse.self, from: data),
               decoded.success {
                DispatchQueue.main.async {
                    self.reviewList = decoded.reviews
                    print("reviewList.count =", self.reviewList.count)
                }
            } else {
                print("review_list decode fail")
            }
        }.resume()
    }

    func addBookToUserList() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/insert_user_book.php") else { return }

        let user_id = UserDefaults.standard.integer(forKey: "loginUserID")
        print("insert_user_book user_id =", user_id, "book_id =", book_id)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "user_id=\(user_id)&book_id=\(book_id)"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }

            print("insert_user_book resp:", String(decoding: data, as: UTF8.self))

            if let decoded = try? JSONDecoder().decode(AddBookResponse.self, from: data),
               decoded.status == "success" {
                DispatchQueue.main.async {
                    goToMain = true
                }
            }
        }.resume()
    }
}

// MARK: - 리뷰 리스트 / 셀

struct ReviewListView: View {
    @Binding var reviewList: [ReviewListItem]

    var body: some View {
        if reviewList.isEmpty {
            Text("아직 등록된 감상평이 없습니다.")
                .foregroundColor(.gray)
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(reviewList) { item in
                    ReviewRowView(review: item)
                }
            }
            .padding(.top, 8)
        }
    }
}

struct ReviewRowView: View {
    @State var review: ReviewListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.nickname ?? "익명")
                    .font(.headline)
                Spacer()
                Text(review.update_date ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(review.content)
                .font(.body)

            HStack {
                Button(action: {
                    likeReview()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundColor(.green)
                        Text(review.likes_count ?? "0")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }



    func likeReview() {
        var req = URLRequest(
            url: URL(string: "http://124.56.5.77/talkseo/ip02/review_like.php")!
        )
        req.httpMethod = "POST"
        let userID = UserDefaults.standard.integer(forKey: "loginUserID")
        req.httpBody =
            "review_id=\(review.review_id)&user_id=\(userID)"
            .data(using: .utf8)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool,
                  success
            else { return }

            let mode = json["mode"] as? String ?? "like"
            let current = Int(review.likes_count ?? "0") ?? 0
            let delta = (mode == "unlike") ? -1 : 1

            DispatchQueue.main.async {
                review = ReviewListItem(
                    review_id: review.review_id,
                    content: review.content,
                    likes_count: String(max(0, current + delta)),
                    update_date: review.update_date,
                    start_date: review.start_date,
                    end_date: review.end_date,
                    nickname: review.nickname
                )
            }
        }.resume()
    }
}
#Preview {
    NavigationStack {
        SearchDetailView(userID: 1, book_id: "1")
    }
}

