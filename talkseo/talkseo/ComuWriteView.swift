//
//  ComuWriteView.swift
//  talkseo3
//
//  Created by mac11 on 12/1/25.
//

import SwiftUI

struct PostToEdit: Codable {
    var result: String?
    var title: String?
    var content: String?
    var message: String?
}

struct PostResult: Codable {
    let result: String? // "success" 또는 "error"
    let message: String?
    let post_id: Int?
}

struct ComuWriteView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    let current_user_id = UserDefaults.standard.integer(forKey: "loginUserID")
    
    var post_id_to_edit: Int?
    
    @Environment(\.dismiss) var dismiss
    
    var onPostCompleted: (() -> Void)?
    
    
    private func loadPostForEdit(postId: Int) {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu_post_load.php") else { return }
        
        let body = "post_id=\(postId)&user_id=\(current_user_id)"
        let encodedData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let postData = try JSONDecoder().decode(PostToEdit.self, from: data)
                
                if postData.result == "success",
                   let loadedTitle = postData.title,
                   let loadedContent = postData.content {
                    DispatchQueue.main.async {
                        self.title = loadedTitle
                        self.content = loadedContent
                        print("수정 데이터 로드 성공: \(loadedTitle)")
                    }
                } else {
                    print("데이터 로드 실패: \(postData.message ?? "게시글 없음/권한 없음")")
                }
            } catch {
                print("수정 데이터 디코딩 실패:", error)
            }
        }.resume()
    }
    
    private func sendPost() {
        guard !title.isEmpty && !content.isEmpty else { return }
        
        let isEditing = post_id_to_edit != nil
        
        let phpFileName = isEditing ? "comu_update.php" : "comu_write.php"
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/\(phpFileName)") else {
            print("URL error")
            return
        }
        
        var params = "user_id=\(current_user_id)&title=\(title)&content=\(content)"
        if isEditing, let postId = post_id_to_edit {
            params += "&post_id=\(postId)"
        }
        
        guard let postData = params.data(using: .utf8) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("네트워크 에러:", error ?? "데이터 없음")
                return
            }
            
            do {
                let resultObject = try JSONDecoder().decode(PostResult.self, from: data)
                
                DispatchQueue.main.async {
                    print("응답:", resultObject.result ?? "nil")
                    print("메시지:", resultObject.message ?? "")
                    
                    if resultObject.result == "success" {
                        onPostCompleted?()
                        dismiss()
                    } else {
                        print("게시글 처리 실패: \(resultObject.message ?? "서버 오류")")
                    }
                }
            } catch {
                print("JSON 디코딩 오류:", error)
            }
        }.resume()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .leading) {
                        if title.isEmpty {
                            Text("제목을 입력해주세요.")
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                        }
                        TextField("", text: $title)
                            .padding(.vertical, 8)
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray),
                        alignment: .bottom
                    )
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("내용을 입력해주세요.")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 150, maxHeight: .infinity)
                            .padding(8)
                            .opacity(content.isEmpty ? 0.9 : 1)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                
                Spacer()
                
                Button(action: sendPost) {
                    Text(post_id_to_edit == nil ? "작성하기" : "수정하기")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty || content.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(title.isEmpty || content.isEmpty)
                .padding()
            }
            .onAppear {
                if let postId = post_id_to_edit {
                    loadPostForEdit(postId: postId)
                }
            }
            .navigationTitle(post_id_to_edit == nil ? "새 글 작성" : "글 수정")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}
