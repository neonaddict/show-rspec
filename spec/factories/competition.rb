FactoryBot.define do
  factory :competition do
    association :startup, factory: :startup
    data do
      {
        'team_competence' => { 'skey' => 'team_competence_interface_designer', 'answer' => '' },
        'team_expectations' => { 'skey' => '', 'answer' => 'do something' },
        'team_remote_employee' => { 'skey' => 'team_remote_employee_yes', 'answer' => '' },
        'team_member_employment' => { 'skey' => 'team_member_employment_20_to_40', 'answer' => '' },
        'team_new_participant_condition' => { 'skey' => %w[team_new_participant_condition_hourly_payment team_new_participant_condition_portion_project], 'answer' => '' }
      }
    end
    state 0
    candidate_refused 0
    rating 0
    selected_first 0
  end
end
