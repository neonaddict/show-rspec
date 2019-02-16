require 'spec_helper'
include Rails.application.routes.url_helpers

RSpec.describe TextChatsController, type: :controller do
  context 'Cofoundit chats' do
    describe 'Candidate' do
      before(:each) do
        @cofoundit_chat = create(:text_chat, :cofoundit)
      end
      it 'can create chat and it redirects' do
        sign_in @cofoundit_chat.expertable
        get :show, id: @cofoundit_chat.chat_id
        expect(response.code).to eq('200')
        get :show, id: @cofoundit_chat.chat_id, format: :json
        expect(JSON.parse(response.body)['redirect_link']).to eq("http://test.host#{cofoundit_profile_selection_results_path}")
      end
      it "can't open chat, that doesn't belongs to him" do
        @candidate = create(:cofoundit_candidate)
        sign_in @candidate
        get :show, id: @cofoundit_chat.chat_id
        expect(response.code).to eq('404')
      end
    end
    describe 'Startup' do
      before(:each) do
        @cofoundit_chat = create(:text_chat, :cofoundit)
      end
      it 'can open chat, that belongs to him' do
        sign_in @cofoundit_chat.userable
        get :show, id: @cofoundit_chat.chat_id
        expect(response.code).to eq('200')
        get :show, id: @cofoundit_chat.chat_id, format: :json
        expect(JSON.parse(response.body)['redirect_link']).to eq("http://test.host#{profile_path}")
      end
      it "can't open chat, that doesn't belongs to him" do
        @cofoundit_chat = create(:text_chat, :cofoundit)
        @startup = create(:user, :startup)
        sign_in @startup
        get :show, id: @cofoundit_chat.chat_id
        expect(response.code).to eq('404')
      end
    end
  end

  context 'NSS chats' do
    before(:each) do
      @nss_chat = create(:text_chat, :nss)
    end
    describe 'Expert' do
      it 'can open chat, that belongs to him' do
        sign_in @nss_chat.expertable
        get :show, id: @nss_chat.chat_id
        expect(response.code).to eq('200')
        get :show, id: @nss_chat.chat_id, format: :json
        expect(JSON.parse(response.body)['redirect_link']).to eq("http://test.host#{profile_path}")
      end
      it "can't open chat, that doesn't belongs to him" do
        @expert = create(:user, :expert)
        sign_in @expert
        get :show, id: @nss_chat.chat_id
        expect(response.code).to eq('404')
      end
    end
    describe 'Startup' do
      it 'can open chat, that belongs to him' do
        sign_in @nss_chat.userable
        get :show, id: @nss_chat.chat_id
        expect(response.code).to eq('200')
        get :show, id: @nss_chat.chat_id, format: :json
        expect(JSON.parse(response.body)['redirect_link']).to eq("http://test.host#{profile_path}")
      end
      it "can't open chat, that doesn't belongs to him" do
        @startup = create(:user, :startup)
        sign_in @startup
        get :show, id: @nss_chat.chat_id
        expect(response.code).to eq('404')
      end
    end
  end
end
