FactoryBot.define do
  factory :user do
    sequence(:name) { Faker::Name.name.split(' ').first }
    sequence(:email) { |n| "user#{n}@email.com" }
    sequence(:lastname) { Faker::Name.name.split(' ').second }
    uuid { SecureRandom.uuid }
    password 'password'
    phone '89999999999'

    city 'Москва'
    country { 'Россия' }

    transient do
      roles [User::DEFAULT_ROLE]
    end

    after :build do |user, evaluator|
      user.roles = evaluator.roles
    end

    after :create do |user, _evaluator|
      user.startup.update_column(:uuid, SecureRandom.uuid)
      user.startup.update_column(:title, 'Startup Title')
    end

    trait :admin do
      transient do
        roles %w[admin]
      end
    end

    trait :admin_ot do
      transient do
        roles %w[admin]
      end
      admin_functions online_tracking: true
    end

    trait :partner do
      transient do
        roles %w[partner]
      end
    end

    trait :expert do
      transient do
        roles %w[expert]
      end
    end

    trait :start_startup do
      admin_functions ({ 'preac' => true, 'start_startup' => true })
      functions ({ 'start_startup' => true })
    end

    trait :with_invite do
      association :startup, factory: :startup_with_invite
    end

    trait :startup do
      transient do
        roles %w[startup]
      end
    end

    trait :account do
      transient do
        roles %w[account]
      end
    end

    factory :start_startup_expert, traits: %i[expert start_startup]
    factory :start_startup_user, traits: %i[startup with_invite]

    trait :marathon do
      email 'marafon@iidf.ru'
      transient do
        roles %w[partner]
      end
    end
  end
end
