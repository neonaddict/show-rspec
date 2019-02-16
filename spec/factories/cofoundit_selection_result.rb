FactoryBot.define do
  factory :cofoundit_selection_result, class: 'Cofoundit::SelectionResult' do
    association :competition, factory: :competition
    association :candidate, factory: :cofoundit_candidate
    status 0
    startup_status -1
  end
end
