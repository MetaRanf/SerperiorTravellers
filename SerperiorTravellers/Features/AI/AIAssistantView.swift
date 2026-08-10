import SwiftUI

public struct AIAssistantView: View {
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var viewModel = AIAssistantViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { msg in
                        HStack {
                            if msg.isUser { Spacer() }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(msg.text).typography(AppTypography.subheadline).padding(12)
                                    .background(msg.isUser ? AppColors.primary : AppColors.cardBackground)
                                    .foregroundStyle(msg.isUser ? Color.white : AppColors.textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                if let detail = msg.detail {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(detail.highlights, id: \.self) { h in TagChip(title: h) }
                                    }
                                }
                            }.frame(maxWidth: 300, alignment: msg.isUser ? .trailing : .leading)
                            if !msg.isUser { Spacer() }
                        }
                    }
                    if viewModel.isThinking { ProgressView().padding() }
                }.padding()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.suggestions, id: \.self) { s in
                        TagChip(title: s) { viewModel.inputText = s; viewModel.send() }
                    }
                }.padding(.horizontal)
            }.padding(.vertical, 8)

            HStack(spacing: 8) {
                TextField("Ask about flights, bookings...", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { viewModel.send() }
                Button { viewModel.send() } label: {
                    Image(systemName: "arrow.up.circle.fill").font(.title2).foregroundStyle(AppColors.primary)
                }.disabled(viewModel.inputText.isEmpty)
            }.padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.configure(aiService: dependencies.aiService) }
    }
}
