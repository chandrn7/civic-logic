# frozen_string_literal: true

module Admin
  class ReportedStatusesController < BaseController
    before_action :set_report

    def create
      authorize :status, :update?

      @form         = Form::StatusBatch.new(form_status_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.target_account  = @report.target_account
      flash[:alert] = I18n.t('admin.statuses.failed_to_execute') unless @form.save

      redirect_to admin_report_path(@report)
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.statuses.no_status_selected')

      redirect_to admin_report_path(@report)
    end

    private

    def status_params
      params.require(:status).permit(:sensitive)
    end

    def form_status_batch_params
      params.require(:form_status_batch).permit(:email_collection => [:text, :send_email_notification], status_ids: [])
    end

    def action_from_button
      if params[:nsfw_on]
        'nsfw_on'
      elsif params[:nsfw_off]
        'nsfw_off'
      elsif params[:delete]
        'delete'
      elsif params[:disable_replies]
        'disable_replies'
      elsif params[:enable_replies]
        'enable_replies'
      elsif params[:restore]
        'restore'
      end
    end

    def set_report
      @report = Report.find(params[:report_id])
    end
  end
end
