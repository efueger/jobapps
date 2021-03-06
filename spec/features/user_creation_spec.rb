require 'rails_helper'

describe 'creating users' do
  before :each do
    when_current_user_is :staff, integration: true
    visit new_user_path
  end

  # staff attribute is a hidden field in the form,
  # so no need to fill it in
  let!(:user_fields) { attributes_for(:user).except :staff }

  context 'with required form elements filled in' do
    before :each do
      within 'form.new_user' do
        fill_in_fields_for User, attributes: user_fields
      end
    end
    it 'renders the staff dashboard' do
      click_on 'Save changes'
      expect(page.current_url).to eql staff_dashboard_url
    end
    it 'creates a user' do
      expect { click_on 'Save changes' }
        .to change { User.count }.by 1
    end
    it 'has a flash message' do
      expect_flash_message(:user_create)
      click_on 'Save changes'
    end
  end

  context 'with a required form element not filled in' do
    it 'renders the new user page' do
      click_on 'Save changes'
      expect(page.current_url).to eql new_user_url
    end
    it 'does not create a user' do
      expect { click_on 'Save changes' }
        .not_to change { User.count }
    end
    it 'has flash errors' do
      click_on 'Save changes'
      expect(page).to have_selector '#errors', text: "First name can't be blank"
    end
  end
end
