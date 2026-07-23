import SwiftUI

struct WriteReviewMainView: View {
    var review: ReviewItem
    var bookTitle: String
    
    @State private var isDeleted = false
    var onDelete: (()-> Void)? = nil
    
    var formattedStartDate: String {
        guard let dateString = review.start_date else {return "----.--.--"}
        return formatDateString(dateString)
    }
    var formattedEndDate: String {
        guard let dateString = review.end_date else {return "----.--.--"}
        return formatDateString(dateString)
    }
    
    var body: some View {
        ScrollView {
            if isDeleted {
                VStack {
                    Spacer()
                    Text("리뷰가 존재하지 않습니다.")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    // 기존 상단 메뉴, 정보, 독서기간, 감상평 UI 등
                    HStack { Spacer()
                        Menu { NavigationLink(
                            destination: BookWriteView(
                                userBookId: review.user_book_id ?? "",
                                title: bookTitle,
                                initialReview: review,
                                reviewComplete: nil
                            )
                        ) {
                            Label("수정하기", systemImage: "pencil")
                        }
                            Button(role: .destructive, action: {
                                deleteReview()})
                            {Label("삭제하기", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title)
                                .padding(.trailing, 10)
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(bookTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: review.visibility == "0" ? "lock.open.fill" : "lock.fill")
                                    .font(.caption)
                                Text(review.visibility == "0" ? "전체공개" : "나만 보기")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(review.visibility == "0" ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .foregroundColor(review.visibility == "0" ? .green : .gray)
                            .cornerRadius(20)
                            
                            if review.is_spoiler == "0" || review.is_spoiler == "true" {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.caption)
                                    Text("스포일러 포함")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    Divider()
                        .padding(.horizontal, 8)
                    
                    // 독서 기간
                    VStack(alignment: .leading, spacing: 8) {
                        Text("독서기간")
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                        
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text("시작")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(formattedStartDate)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 1, height: 14)
                                .padding(.horizontal, 8)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text("종료")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(formattedEndDate)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            Spacer()}.padding(16).background(Color.gray.opacity(0.05)).cornerRadius(12).padding(.horizontal, 8)
                        
                            // 감상평 내용
                            VStack(alignment: .leading, spacing: 8) {
                                Text("감상평")
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                
                                ZStack(alignment: .topLeading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Text(review.content ?? "내용이 없습니다.")
                                        .font(.body)
                                        .lineSpacing(6)
                                        .padding(20)
                                }
                                .padding(.horizontal, 8)
                            }
                            
                            Spacer()
                        }
                        .padding(.top)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }                }
            
        }
        
        func formatDateString(_ dateString: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                formatter.dateFormat = "yyyy.MM.dd"
                return formatter.string(from: date)
        }
            return dateString
        }
        
        func deleteReview() {
            guard let userBookId = review.user_book_id,
                  let url = URL(string: "http://124.56.5.77/talkseo/ip02/review_save.php") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let bodyString = "user_book_id=\(userBookId)&action=delete"
            request.httpBody = bodyString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("삭제 중 오류: \(error.localizedDescription)")
                    return
                }
                guard let data = data else { return }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("서버 응답: \(responseString)")
                    
                    DispatchQueue.main.async {
                        isDeleted = true
                        onDelete?()
                    }
                }
            }.resume()
        }
    }

#Preview {
    WriteReviewMainView(
        review: ReviewItem(
            user_book_id: "1",
            start_date: "2025-11-01",
            end_date: "2025-11-10",
            content: "이 책은 인상 깊은 문장들이 많았고, 읽는 동안 여러 감정이 자연스럽게 이어졌다. 여운이 오래 남는 작품이었다.",
            visibility: "1",
            is_spoiler: "0"
        ),
        bookTitle: "사서함 110호의 우편물"
    )
}
