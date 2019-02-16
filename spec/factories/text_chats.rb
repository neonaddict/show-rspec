FactoryBot.define do
  factory :text_chat, class: 'TextChat' do
    chat_id { SecureRandom.hex(10) }
    trait :cofoundit do
      association :event, factory: :cofoundit_selection_result
      association :userable, factory: :user do
        user :startup
      end
      association :expertable, factory: :cofoundit_candidate
    end

    trait :cofoundit_with_message do
      after(:create) do |text_chat|
        text_chat.chat_messages << create(:message_cofoundit)
      end
    end

    trait :nss do
      association :event, factory: :start_startup_invite
      association :expertable, factory: :start_startup_expert
      after(:build) do |text_chat|
        text_chat.userable = text_chat.event.startup.user
      end
    end

    trait :nss_with_message do
      after(:create) do |text_chat|
        text_chat.chat_messages << create(:message_nss)
      end
    end

    factory :cofoundit_chat_with_message, traits: %i[cofoundit cofoundit_with_message]
    factory :nss_chat_with_message, traits: %i[nss nss_with_message]
  end
end
