require 'rails_helper'

RSpec.describe ParlamentController, type: :controller do
  describe 'POST #presence' do
    let(:valid_token) { Rails.application.credentials.presence_api_key }
    let(:invalid_token) { 'invalid_token' }
    let(:parlament_state) { instance_double(ParlamentState) }

    context 'with valid token' do
      before do
        allow(ParlamentState).to receive(:instance).and_return(parlament_state)
        request.headers['Authorization'] = "Token token=\"#{valid_token}\""

      end

      it 'returns http success' do
        expect(parlament_state).to receive(:presence=)
        post :presence, params: { state: "On" }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = "Token token=\"#{invalid_token}\""
        post :presence, params: { state: "Off" }
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
