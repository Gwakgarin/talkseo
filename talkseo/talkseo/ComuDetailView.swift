//
//  ComuDetailView.swift
//  talkseo
//
//  Created by mac28 on 10/27/25.
//

import SwiftUI

struct Detail_Post: Codable {
    var user_id:String?
    var nickname:String?
    var profile_image_url:String?
    var content:String?
    var insert_date:String?
    var post_id:Int?
    var title:String?
    var like_count:Int?
    var comment_count:Int?
    var is_liked_by_me:Int?
}

struct Detail_PostItem:View {
    @State var Detail_postData : Detail_Post
    
    var current_user_id: Int
    var deletePostAction: (Int) -> Void
    
    var onUpdateAction: () -> Void
    
    var body: some View {
        
        let isMyPost = (Detail_postData.user_id == String(current_user_id))
        let postId = Detail_postData.post_id ?? 0
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12){
                if let urlString = Detail_postData.profile_image_url,
                   let url = URL(string: urlString),
                   !urlString.isEmpty {
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading){
                    Text(Detail_postData.nickname ?? "익명 사용자")
                        .font(.headline)
                    Text(Detail_postData.insert_date ?? "날짜 미상")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                if isMyPost {
                    Menu {
                        Button(action: onUpdateAction) {
                            Label("수정하기", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            deletePostAction(postId)
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                    .offset(y: -8)
                }
            }
            .padding(.bottom, 8.0)
            Text(Detail_postData.title ?? "")
                .fontWeight(.bold)
                .font(.system(size: 20))
                .lineLimit(nil)
            Text(Detail_postData.content ?? "")
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Text(Detail_postData.profile_image_url ?? "")
        }
    }
}

struct Detail_Posts: Codable{
    var COMMUNITY_POST:[Detail_Post]
}

struct Comment: Codable {
    var post_comment_id: Int?
    var user_id: String?
    var nickname: String?
    var profile_image_url: String?
    var content: String?
    var insert_date: String?
    var parent_comment_id: Int?
}

struct CommentItem: View {
    @State var commentData: Comment
    var current_user_id: Int
    var replyAction: () -> Void
    var deleteAction: (Int) -> Void

    var body: some View {
        let isReply = (commentData.parent_comment_id != 0)
        let isMyComment = (commentData.user_id == String(current_user_id))
        let commentId = commentData.post_comment_id ?? 0
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                if let urlString = commentData.profile_image_url,
                   let url = URL(string: urlString),
                   !urlString.isEmpty {
                    
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(commentData.nickname ?? "익명 사용자")
                        .font(.headline)
                    Text(commentData.insert_date ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isMyComment {
                    Menu {
                        Button(role: .destructive) {
                            deleteAction(commentId)
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 4)
                    .offset(y: 8)
                }
                if !isReply {
                    Button(action: {
                        replyAction()
                    }) {
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.gray.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            Text(commentData.content ?? "")
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(isReply ? Color(.systemGray6) : Color.white)
        .cornerRadius(8)
        .padding(.leading, isReply ? 30 : 0)
    }
}

struct Comments: Codable{
    var POST_COMMENT:[Comment]
}

struct DeletionResult: Codable {
    let result: String
    let message: String?
}

struct ComuDetailView: View {
    let current_user_id = UserDefaults.standard.integer(forKey: "loginUserID")
    let post_id: Int
    
    @State var COMMUNITY_POST: Detail_Posts = Detail_Posts(COMMUNITY_POST: [Detail_Post]())
    @State var POST_COMMENT: [Comment] = []
    
    @State private var newComment: String = ""
    @FocusState private var inputFocused: Bool
    
    @State var parentCommentId: Int = 0
    
    @State private var isShowingEditView: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    private func reloadPostDetail() {
            guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comudetail.php")
            else {
                print("url error")
                return
            }
            let body = "user_id=\(current_user_id)&post_id=\(post_id)"
            let encodedData = body.data(using: String.Encoding.utf8)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = encodedData
            
            URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                guard let data = data else { return }
                
                do {
                    let str2 = String(decoding: data, as: UTF8.self)
                    print("게시글 재로드 JSON:", str2)
                    
                    let decoder = JSONDecoder()
                    if let jsonData = try? decoder.decode(Detail_Posts.self, from: data) {
                        DispatchQueue.main.async {
                            COMMUNITY_POST = jsonData
                            loadComments(post_id: post_id)
                        }
                    }
                }
            }.resume()
        }
    
    func deletePost(postId: Int) {
        print("게시글 ID \(postId) 삭제 요청. 사용자 ID: \(current_user_id)")
        
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu_post_delete.php") else { return }
        
        let body = "post_id=\(postId)&user_id=\(current_user_id)"
        let encodedData = body.data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("게시글 삭제 에러:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let resultObject = try JSONDecoder().decode(DeletionResult.self, from: data)

                if resultObject.result == "success" {
                    DispatchQueue.main.async {
                        print("게시글 삭제 성공, 화면 닫기.")
                        dismiss()
                    }
                } else {
                    DispatchQueue.main.async {
                        print("게시글 삭제 실패: \(resultObject.message ?? "서버 오류")")
                    }
                }
            } catch {
                 print("게시글 삭제 응답 디코딩 실패:", error)
            }
        }.resume()
    }
    
    func deleteComment(commentId: Int) {
        print("댓글 ID \(commentId) 삭제 요청. 사용자 ID: \(current_user_id)")
        
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu_comment_delete.php") else { return }
        
        let body = "post_comment_id=\(commentId)&user_id=\(current_user_id)"
        
        let encodedData = body.data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("댓글 삭제 에러:", error)
                return
            }
            
            guard let data = data else { return }
            
            if let result = String(data: data, encoding: .utf8) {
                print("댓글 삭제 성공:", result)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                loadComments(post_id: post_id)
            }
        }
        .resume()
    }
    
    func loadComments(post_id: Int) {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu_comment.php") else {
            print("comment url error")
            return
        }
        
        let body = "post_id=\(post_id)"
        let encodedData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("댓글 API 에러:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let str = String(decoding: data, as: UTF8.self)
                print("댓글 JSON →", str)
                
                let decoder = JSONDecoder()
                
                if let jsonData = try? decoder.decode(Comments.self, from: data) {
                    DispatchQueue.main.async {
                        self.POST_COMMENT = jsonData.POST_COMMENT
                    }
                }
            }
        }.resume()
    }
    
    func sendComment() {
        guard !newComment.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu_comment_insert.php") else { return }
        
        let body = "user_id=\(current_user_id)&post_id=\(post_id)&content=\(newComment)&parent_comment_id=\(parentCommentId)"

        let encodedData = body.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("댓글 입력 에러:", error)
                return
            }
            
            guard let data = data else { return }
            
            if let result = String(data: data, encoding: .utf8) {
                print("댓글 입력 응답:", result)
            }
            DispatchQueue.main.async {
                newComment = ""
                parentCommentId = 0
                loadComments(post_id: post_id)
            }
            
        }.resume()
    }
    
    func sortedComments() -> [Comment] {
        var result: [Comment] = []
        let parents = POST_COMMENT.filter { $0.parent_comment_id == 0 }
        let children = POST_COMMENT.filter { $0.parent_comment_id != 0 }

        for parent in parents {
            result.append(parent)

            let replies = children.filter { $0.parent_comment_id == parent.post_comment_id }
            result.append(contentsOf: replies)
        }

        return result
    }

    func toggleLike() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu_like.php")
        else {
            print("url error")
            return
        }
        let body = "user_id=\(current_user_id)&post_id=\(post_id)"
        let encodedData = body.data(using: String.Encoding.utf8)
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        URLSession.shared.dataTask(with: request) {
            
            (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                return
            }
            
            let responseStr = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            print("Server response: \(responseStr)")
            
            let str = String(decoding: data, as: UTF8.self)
            print("data ? \(str)")
            
            let is_liked_by_me_response = Int(responseStr)
            
            if let is_liked_by_me = Int(responseStr), is_liked_by_me > 0 {
                print("좋아요")
                DispatchQueue.main.async {
                    if !COMMUNITY_POST.COMMUNITY_POST.isEmpty {
                        COMMUNITY_POST.COMMUNITY_POST[0].is_liked_by_me = is_liked_by_me
                    }
                }
            }
            else if is_liked_by_me_response == 0 {
                print("좋아요 취소")
                DispatchQueue.main.async {
                    if !COMMUNITY_POST.COMMUNITY_POST.isEmpty {
                        COMMUNITY_POST.COMMUNITY_POST[0].is_liked_by_me = 0
                    }
                }
            }
        }.resume()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                destination: ComuWriteView(
                    post_id_to_edit: post_id,
                    onPostCompleted: reloadPostDetail
                ),
                isActive: $isShowingEditView,
                label: { EmptyView() }
            )
            .frame(width: 0, height: 0)
            .hidden()
            ScrollView {
                VStack {
                    ForEach(COMMUNITY_POST.COMMUNITY_POST, id:\.post_id) { content in
                        Detail_PostItem(
                            Detail_postData: content,
                            current_user_id: current_user_id,
                            deletePostAction: deletePost,
                            onUpdateAction: { self.isShowingEditView = true }
                        )
                        .padding(.horizontal, 30.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let postData = COMMUNITY_POST.COMMUNITY_POST.first {
                        HStack {
                            Button(action: toggleLike) {
                                HStack(spacing: 4) {
                                    Image(systemName: postData.is_liked_by_me == 1 ? "heart.fill" : "heart")
                                        .foregroundColor(postData.is_liked_by_me == 1 ? .red : .black)
                                    
                                    Text("좋아요")
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 20)
                            
                            Button(action: {
                                print("댓글 버튼 클릭")
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "message")
                                        .foregroundColor(.black)
                                    
                                    Text("댓글")
                                        .foregroundColor(.black)
                                    
                                    Text(String(postData.comment_count ?? 0))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10)
                        .background(Color.white)
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(sortedComments(), id: \.post_comment_id) { comment in
                                CommentItem(
                                    commentData: comment,
                                    current_user_id: current_user_id,
                                    replyAction: {
                                        self.parentCommentId = comment.post_comment_id ?? 0
                                        self.inputFocused = true
                                    },
                                    deleteAction: deleteComment
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
                .padding(.horizontal, 0)
            HStack {
                TextField("댓글을 입력하세요...", text: $newComment)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .focused($inputFocused)
                
                Button(action: { sendComment() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.leading, 6)
            }
            .padding()
            .background(Color.white)
        }
        .onAppear() {
            guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comudetail.php")
            else {
                print("url error")
                return
            }
            let body = "user_id=\(current_user_id)&post_id=\(post_id)"
            let encodedData = body.data(using: String.Encoding.utf8)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = encodedData
            
            URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let str2 = String(decoding: data, as: UTF8.self)
                    print(str2)
                    
                    let decoder = JSONDecoder()
                    if let jsonData = try? decoder.decode(Detail_Posts.self, from: data) {
                        COMMUNITY_POST = jsonData
                    }
                    loadComments(post_id: post_id)
                }
            }.resume()
        }
    }
}

#Preview {
    ComuDetailView(post_id: 1)
}

