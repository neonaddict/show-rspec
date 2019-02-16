require 'spec_helper'

describe Competition do
  let(:competition) { create(:competition) }
  let(:new_competition) { build(:competition) }
  let(:selection_data) { build(:cofoundit_selection_data) }

  describe 'selection startups mechanism' do
    before(:each) do
      ActiveRecord::Base.connection.disconnect!
      system('cat ./spec/fixtures/sql/triggers.dump| psql preacc_test')
      system('cat ./spec/fixtures/sql/mail_templates.dump | psql preacc_test')
      ActiveRecord::Base.establish_connection
      selection_data.candidate.update(current_selection_data: selection_data)
    end

    it 'works!' do
      new_comp = competition
      Cofoundit::SelectionStartups.new([selection_data.candidate], 5).call
      new_comp.reload

      expect(new_comp.results.count).to eq(1)
    end

    it 'right with statuses' do
      new_comp = competition
      statuses = Cofoundit::SelectionResult.statuses
      statuses.delete('startup_found')

      result = Cofoundit::SelectionResult.create(
        competition_id: new_comp.id,
        cofoundit_candidate_id: selection_data.candidate.id,
        status: 0, startup_status: 0
      )

      statuses.each do |st|
        result.update(status: st[1])
        result.reload

        status = result.status
        startup_status = result.startup_status

        new_results = Cofoundit::SelectionStartups.new([selection_data.candidate], 5).call
        expect(new_results.first[:competition_ids]).to be_empty

        result.reload

        expect(new_comp.results.count).to eq(1)
        expect(result.status).to eq(status)
        expect(result.startup_status).to eq(startup_status)
      end
    end

    it 'find and update if only startup found' do
      new_comp = competition
      Cofoundit::SelectionResult.create(
        competition_id: new_comp.id,
        cofoundit_candidate_id: selection_data.candidate.id, startup_status: 0
      )

      new_results = Cofoundit::SelectionStartups.new([selection_data.candidate], 5).call
      result = new_comp.results.first

      expect(new_results.first[:competition_ids]).not_to be_empty
      expect(new_comp.results.count).to eq(1)
      expect(result.status).to eq('init')
      expect(result.startup_status).to eq('found')
    end
  end

  describe 'selection candidates mechanism' do
    before(:each) do
      # Load anketa
      require 'rake'
      PreAcc::Application.load_tasks
      Rake::Task['db:seed:anketa:versions'].invoke
      ENV['VERSION'] = 'base_v11'
      Rake::Task['db:seed:anketa:load'].invoke
      ENV.delete('VERSION')

      @candidate = selection_data.candidate

      new_competition.save

      @candidate.update(current_selection_data: selection_data)

      Cofoundit::Anketa::CandidateVersion.create(version: Cofoundit::Anketa::Version.last, candidate: @candidate)

      @candidate_version = @candidate.candidate_versions.first

      @question = @candidate_version.version.questions.find_by(skey: 'team_new_participant_condition')
      Cofoundit::Anketa::Reply.create(candidate_version_id: @candidate_version.id, question_id: @question.id, draft: false, data: { 'option_ids' => @question.options.pluck(:id) }, asked: true, cofoundit_candidate_id: @candidate.id)

      @question = @candidate_version.version.questions.find_by(skey: 'timing')
      Cofoundit::Anketa::Reply.create(candidate_version_id: @candidate_version.id, question_id: @question.id, draft: false, data: { 'option_ids' => @question.options.pluck(:id) }, asked: true, cofoundit_candidate_id: @candidate.id)
    end

    it 'works!' do
      new_competition.selection_candidate
      new_competition.reload

      expect(new_competition.results.count).to eq(1)
    end

    it 'dont update startup_status and dont create new selection_result' do
      result = Cofoundit::SelectionResult.create(
        competition_id: new_competition.id,
        cofoundit_candidate_id: selection_data.candidate.id,
        status: 0, startup_status: -1
      )

      statuses = [1, 4, 7, 8, 9, 5, 2, 3, 12]

      statuses.each do |st|
        result.update_columns(status: st, startup_status: 2)
        result.reload

        new_competition.selection_candidate
        new_competition.reload

        expect(new_competition.results.count).to eq(1)

        new_result = new_competition.results.first

        expect(new_result.status).to eq(result.status)
        expect(new_result.startup_status).to eq('candidate_status')
      end
    end

    it 'change startup_status after selection_candidate' do
      result = Cofoundit::SelectionResult.create(
        competition_id: new_competition.id,
        cofoundit_candidate_id: selection_data.candidate.id,
        status: 0, startup_status: -1
      )

      statuses = [0, 10, 6, 11]

      statuses.each do |st|
        result.update(status: st)
        result.update(startup_status: -1)

        new_competition.selection_candidate
        new_competition.reload

        expect(new_competition.results.count).to eq(1)

        expect(new_competition.results.first.startup_status).to eq('found')
      end
    end
  end
end
