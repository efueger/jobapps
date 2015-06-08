require 'rails_helper'

describe QuestionsController do
  describe 'POST #create' do
    before :each do
      @question = attributes_with_foreign_keys_for :question
      @path = 'http://test.host/redirect'
    end
    let :submit do
      request.env['HTTP_REFERER'] = @path
      post :create, question: @question
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'invalid input' do
        before :each do
          @question = { number: '' }
        end
        it 'displays errors' do
          submit
          expect(flash.keys).to include 'errors'
        end
        it 'redirects back' do
          expect_redirect_to_back(@path) { submit }
        end
      end
      context 'valid input' do
        it 'creates a question as specified' do
          expect { submit }
            .to change { Question.count }
            .by 1
        end
        it 'displays the question_create message' do
          expect_flash_message :question_create
          submit
        end
        it 'redirects back' do
          expect_redirect_to_back(@path) { submit }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @question = create :question
      @path = 'http://test.host/redirect'
    end
    let :submit do
      request.env['HTTP_REFERER'] = @path
      delete :destroy, id: @question.id
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'destroys the question' do
        expect { submit }
          .to change { Question.count }
          .by(-1)
      end
      it 'displays a flash message' do
        submit
        expect(flash.keys).to include 'message'
      end
      it 'redirects back' do
        submit
        expect_redirect_to_back(@path) { submit }
      end
    end
  end

  describe 'POST #move' do
    before :each do
      @question = create :question
      @path = 'http://test.host/redirect'
    end
    let :submit do
      request.env['HTTP_REFERER'] = @path
      post :move, id: @question.id, direction: @direction
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'moving up' do
        before :each do
          @direction = 'up'
        end
        it 'calls #move with :up' do
          expect_any_instance_of(Question)
            .to receive(:move)
            .with :up
          submit
        end
        it 'redirects back' do
          expect_redirect_to_back { submit }
        end
      end
      context 'moving down' do
        before :each do
          @direction = 'down'
        end
        it 'calls #move with :down' do
          expect_any_instance_of(Question)
            .to receive(:move)
            .with :down
          submit
        end
        it 'redirects back' do
          expect_redirect_to_back { submit }
        end
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @question = create :question
      @changes = { number: 2 }
      @path = 'http://test.host/redirect'
    end
    let :submit do
      request.env['HTTP_REFERER'] = @path
      put :update, id: @question.id, question: @changes
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'invalid input' do
        before :each do
          @changes = { number: '' }
        end
        it 'shows errors' do
          submit
          expect(flash.keys).to include 'errors'
        end
        it 'redirects back' do
          expect_redirect_to_back { submit }
        end
      end
      context 'valid input' do
        it 'updates the question as specified' do
          submit
          expect(@question.reload.number).to eql 2
        end
        it 'displays the question update message' do
          expect_flash_message :question_update
          submit
        end
        it 'redirects back' do
          expect_redirect_to_back { submit }
        end
      end
    end
  end
end
