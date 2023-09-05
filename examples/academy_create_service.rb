# frozen_string_literal: true

class AcademyCreateService
  attr_reader :academy, :company_id, :created_by, :params

  def initialize(params, company_id: nil, created_by: nil)
    @params = params
    @company_id = company_id
    @academy = Academy.new
    @created_by = created_by
  end

  def self.call
    resolve_company_name if company.new_record?
    create_academy

    CertificateSettings::Create.call(academy: academy)
    AcademyDefaultSettingsService.call(academy)
    EmailTemplates::CreateAcademyEmailTemplatesService.call(academy: academy)

    result
  end

  private

  def resolve_company_name
    company_name = params.fetch(:company_name, nil) || params.fetch(:name)
    company.name          = company_name
    company.attributes    = params.slice(:contact_phone, :contact_role, :contact_email)

    ::Companies::ProduceCanonicalName.call(company: company)

    validate_company_name
    create_co_admin
  end

  def create_academy
    academy.transaction do
      academy.attributes  = params.slice(:name, :subdomain, :academy_type, :access_type)
      academy.company     = company
      academy.integration_setting ||= IntegrationSetting.new
      academy.save!
      academy.create_academy_dta_setting!
      academy.create_academy_chat_setting!
      academy.create_academy_configuration!
      academy.create_academy_in_company_setting!
      AcademyNamingSettings::Create.call(academy_id: academy.id)
      AcademyVideoWelcomeMessageSettings::Create.call(academy.id)
      PermissionGroups::CreateAcademyTemplates.call(academy: academy)
    end
  end

  def result
    @result ||= { errors: [], academy: academy }
  end

  def validate_company_name
    result[:errors] << 'Company name already used' if company.canonical_name.blank?
  end

  def create_co_admin
    return if created_by.blank?
    return unless created_by.external_admin?

    CoAdmin.create!(external_admin: created_by.external_admin, company: company)
  end

  def company
    @company ||= Company.find_by(id: company_id) || Company.new
  end
end
