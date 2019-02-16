require 'spec_helper'
include Rails.application.routes.url_helpers

describe Cofoundit::TextChatsController, type: :controller do
  before :each do
    @selection_result = create(:cofoundit_selection_result)
    sign_in @selection_result.candidate
  end

  context 'Candidate' do
    describe 'creation of chat' do
      subject { post :create, selection_result_id: @selection_result.id, id: @selection_result.id }
      it 'can create chat' do
        expect { subject }.to change { TextChat.count }.by(1)
        expect(subject).to redirect_to("http://test.host/text_chats/#{TextChat.last.chat_id}")
      end
      it "doesn't create new chat, if already exists" do
        post :create, selection_result_id: @selection_result.id, id: @selection_result.id

        expect { post :create, selection_result_id: @selection_result.id, id: @selection_result.id }.to change { TextChat.count }.by(0)
      end
    end
  end
end
