require 'rails_helper'
require 'csv'

describe ApplicationRecord do
  describe 'between' do
    before :each do
      Timecop.freeze 1.week.ago do
        @too_past_record = create :application_record
      end
      Timecop.freeze 1.month.since do
        @too_future_record = create :application_record
      end
      @just_right_record = create :application_record
      @start_date = Time.zone.today
      @end_date = 1.week.since
    end
    let :call do
      ApplicationRecord.between @start_date, @end_date
    end
    it 'gives the application records between the given dates' do
      expect(call).to include @just_right_record
      expect(call).not_to include @too_future_record, @too_past_record
    end
  end
  describe 'deny_with' do
    before :each do
      @record = create :application_record
      @note = 'a staff note'
    end
    let :call do
      @record.deny_with @note
    end
    it 'updates with the given note' do
      call
      expect(@record.reload.staff_note).to eql @note
    end
    context 'notify_applicant set to true' do
      before :each do
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:on_application_denial, :notify_applicant], anything)
          .and_return true
      end
      it 'sends application denial email' do
        mail = ActionMailer::MessageDelivery.new(JobappsMailer,
                                                 :application_denial)
        expect(JobappsMailer)
          .to receive(:application_denial)
          .with(@record)
          .and_return mail
        expect(mail).to receive(:deliver_now).and_return true
        call
      end
    end
    context 'notify_applicant set to false' do
      before :each do
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:on_application_denial, :notify_applicant], anything)
          .and_return false
      end
      it 'does not send application denial email' do
        expect(JobappsMailer)
          .not_to receive(:application_denial)
        call
      end
    end
  end

  describe 'pending?' do
    it 'returns true if record has not been reviewed' do
      record = create :application_record, reviewed: false
      expect(record.pending?).to eql true
    end
    it 'returns false if record has been reviewed' do
      record = create :application_record, reviewed: true
      expect(record.pending?).to eql false
    end
  end
end
