class ParlamentController < ApplicationController

  before_action :authenticate, only: [:presence]
  skip_before_action :verify_authenticity_token

  def index
  end

  def presence
    presence = params.require(:state) == "On"
    ActionCable.server.broadcast("parlament_presence_channel", { presence: })

    head :ok
  end

  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(token),
        ::Digest::SHA256.hexdigest(Rails.application.credentials.presence_api_key)
      )
    end
  end

  def render_unauthorized
    respond_to do |format|
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      format.html { render plain: "Unauthorized", status: :unauthorized }
    end
  end

end
