# frozen_string_literal: true

class Api::V1::Accounts::ListsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }
  before_action :require_user!
  before_action :set_account
  before_action :require_open_federation!

  def index
    @lists = @account.suspended? ? [] : @account.lists.where(account: current_account)
    render json: @lists, each_serializer: REST::ListSerializer
  end

  private

  def require_open_federation!
    not_found if whitelist_mode?
  end

  def set_account
    @account = Account.find(params[:account_id])
  end
end
