require 'spec_helper'

RSpec.describe StartStartup::TextChatsController, type: :controller do
  context 'NSS Chats' do
    describe 'Expert' do
      before(:each) do
        @expert = create(:start_startup_expert)
        @invite = create(:start_startup_invite)
        sign_in @expert
      end
      subject { get :new, user_id: @invite.startup.user.id }
      it 'can create text chat', focus: true do
        expect { get :new, user_id: @invite.startup.user.id }.to change { TextChat.count }.by(1)
        expect(get(:new, user_id: @invite.startup.user.id)).to redirect_to("http://test.host/text_chats/#{TextChat.last.chat_id}")
      end
      it "doesn't create new chat, if already exist" do
        @nss_chat = create(:nss_chat_with_message)
        sign_in @nss_chat.expertable

        expect { get :new, user_id: @nss_chat.userable.id }.to change { TextChat.count }.by(0)
        expect(get(:new, user_id: @nss_chat.userable.id)).to redirect_to("http://test.host/text_chats/#{TextChat.last.chat_id}")
      end
    end

    describe 'Startup' do
      it 'can go to NSS chat' do
        @nss_chat = create(:nss_chat_with_message)
        sign_in @nss_chat.userable
        expect(get(:show)).to redirect_to("http://test.host/text_chats/#{@nss_chat.chat_id}")
      end
    end
  end
end
