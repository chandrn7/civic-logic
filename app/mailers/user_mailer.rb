# frozen_string_literal: true

class UserMailer < Devise::Mailer
  layout 'mailer'

  helper :accounts
  helper :application
  helper :instance
  helper :statuses

  helper RoutingHelper

  def confirmation_instructions(user, token, **)
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.unconfirmed_email.presence || @resource.email,
           subject: I18n.t(@resource.pending_reconfirmation? ? 'devise.mailer.reconfirmation_instructions.subject' : 'devise.mailer.confirmation_instructions.subject', instance: @instance, title: Setting.site_title),
           template_name: @resource.pending_reconfirmation? ? 'reconfirmation_instructions' : 'confirmation_instructions'
    end
  end

  def reset_password_instructions(user, token, **)
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject', title: Setting.site_title)
    end
  end

  def password_change(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.password_change.subject', title: Setting.site_title)
    end
  end

  def email_changed(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.email_changed.subject', title: Setting.site_title)
    end
  end

  def two_factor_enabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.two_factor_enabled.subject', title: Setting.site_title)
    end
  end

  def two_factor_disabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.two_factor_disabled.subject', title: Setting.site_title)
    end
  end

  def two_factor_recovery_codes_changed(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.two_factor_recovery_codes_changed.subject', title: Setting.site_title)
    end
  end

  def webauthn_enabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_enabled.subject', title: Setting.site_title)
    end
  end

  def webauthn_disabled(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_disabled.subject', title: Setting.site_title)
    end
  end

  def webauthn_credential_added(user, webauthn_credential)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @webauthn_credential = webauthn_credential

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_credential.added.subject', title: Setting.site_title)
    end
  end

  def webauthn_credential_deleted(user, webauthn_credential)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @webauthn_credential = webauthn_credential

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.webauthn_credential.deleted.subject', title: Setting.site_title)
    end
  end

  def welcome(user)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.welcome.subject', title: Setting.site_title)
    end
  end

  def backup_ready(user, backup)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @backup   = backup

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.backup_ready.subject', title: Setting.site_title)
    end
  end

  def warning(user, warning, status_ids = nil)
    @resource = user
    @warning  = warning
    @instance = Rails.configuration.x.local_domain
    @statuses = Status.unscope(where: :pending).with_discarded.where(id: status_ids).includes(:account) if status_ids.is_a?(Array)

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email,
           subject: I18n.t("user_mailer.warning.subject.#{@warning.action}", acct: "@#{user.account.local_username_and_domain}"),
           reply_to: Setting.site_contact_email
    end
  end

  def post_digest(user, status_ids)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @statuses = Status.where(id: status_ids)

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t("user_mailer.post_digest.subject")
    end
  end

  def sign_in_token(user, remote_ip, user_agent, timestamp)
    @resource   = user
    @instance   = Rails.configuration.x.local_domain
    @remote_ip  = remote_ip
    @user_agent = user_agent
    @detection  = Browser.new(user_agent)
    @timestamp  = timestamp.to_time.utc

    return unless @resource.active_for_authentication?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email,
           subject: I18n.t('user_mailer.sign_in_token.subject'),
           reply_to: Setting.site_contact_email
    end
  end
end
