FactoryBot.define do
  factory :start_startup_invite, class: 'StartStartup::Invite' do
    start_at { Faker::Date.between(2.days.ago, Date.today - 1.day) }
    association :expert, factory: :user do
      user :expert
    end
    association :startup, factory: :startup
  end
end
