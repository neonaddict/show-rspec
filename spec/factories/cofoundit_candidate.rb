FactoryBot.define do
  factory :cofoundit_candidate, class: 'Cofoundit::Candidate' do
    sequence(:email) { |n| "cofoundit_candidate#{n}@email.com" }
    sequence(:first_name) { |n| "first_name#{n}" }
    sequence(:city) { |n| "city#{n}" }
    country 'Россия'
    phone '+7 (909) 999-99-99'
    password 'password'
    resume_link 'https://hh.ru'

    after :build do
      FactoryBot.create(:trigger, :candidate, title: '1000_00_00') if Trigger.find_by(title: '1000_00_00').blank?
      FactoryBot.create(:cofoundit_statistic)
    end
  end
end
