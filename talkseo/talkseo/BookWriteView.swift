//
//  BookWriteView.swift
//  talkseo3
//
//  Created by mac11 on 11/20/25.
//
 
import SwiftUI

struct BookWriteView: View {
    var userBookId: String
    var title: String
    var initialReview: ReviewItem?
    var reviewComplete: (() -> Void)?
    
    @State private var content: String = ""
    @State private var visibility: Int = 0  // 0:전체 ,1:나만
    @State private var isSpoiler: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @State private var saveReview: ReviewItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 공개 범위
            HStack {
                Text("공개 범위")
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .leading)
                    .padding(8)
                
                HStack(spacing: 16) {
                    Button(action: { visibility = 1 }) {
                        Text("나만 보기")
                            .foregroundColor(visibility == 1 ? .black : .gray)
                            .fontWeight(visibility == 1 ? .bold : .regular)
                    }
                    Button(action: { visibility = 0 }) {
                        Text("전체공개")
                            .foregroundColor(visibility == 0 ? .black : .gray)
                            .fontWeight(visibility == 0 ? .bold : .regular)
                    }
                }
            }
            
            // 스포 체크
            HStack {
                Text("스포 체크")
                    .fontWeight(.bold)
                    .frame(width: 80, alignment: .leading)
                    .padding(8)
                Toggle("", isOn: $isSpoiler)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .red))
            }
            
            // 감상평 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("감상평")
                    .fontWeight(.bold)
                    .padding(8)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(minHeight: 200)
                        .padding(6)
                    
                    if content.isEmpty {
                        Text("감상평을 작성해주세요.")
                            .foregroundColor(.gray)
                            .padding(12)
                    }
                    
                    TextEditor(text: $content)
                        .padding(4)
                        .frame(minHeight: 200)
                        .opacity(content.isEmpty ? 0.25 : 1)
                }
            }
        }
        
        // 버튼
        Button(action: { saveReviewToServer() }) {
            Text("기록하기")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(content.isEmpty ? Color.gray : Color.white)
                .background(Color.green)
                .cornerRadius(10)
        }
        .padding()
        .navigationTitle("감상평 쓰기")
    }
    
    func saveReviewToServer() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/review_save.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let spoilerInt = isSpoiler ? 0 : 1
        let bodyString = "user_book_id=\(userBookId)&content=\(content)&visibility=\(visibility)&is_spoiler=\(spoilerInt)"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            
            struct SaveResponse: Codable {
                let success: Bool
                let message: String
                let start_date: String?
                let end_date: String?
            }
            
            if let decoded = try? JSONDecoder().decode(SaveResponse.self, from: data),
               decoded.success {
                
                DispatchQueue.main.async {
                    let review = ReviewItem(
                        user_book_id: userBookId,
                        start_date: decoded.start_date,   // 서버 값은 유지
                        end_date: decoded.end_date,
                        content: content,
                        visibility: String(visibility),
                        is_spoiler: isSpoiler ? "0" : "1"
                    )
                    
                    self.saveReview = review
                    self.reviewComplete?()
                    dismiss()
                }
            }
        }.resume()
    }
}


