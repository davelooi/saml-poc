class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => saml_settings)

    # We validate the SAML Response and check if the user already exists in the system
    if response.is_valid?
       # authorize_success, log the user
      user = User.find_or_create_by(email: response.nameid) do |user|
        user.name = "#{response.attributes["firstName"]} #{response.attributes["lastName"]}"
      end
      redirect_to admin_root_path
    else
      authorize_failure  # This method shows an error message
      # List of errors is available in response.errors array
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(saml_settings, true)
  end

  private

  def saml_settings
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    settings = idp_metadata_parser.parse_remote("https://dev-31259947.okta.com/app/exk12zyvyhwQFqZrr5d7/sso/saml/metadata")

    settings.assertion_consumer_service_url = consume_saml_index_url
    settings.sp_entity_id = metadata_saml_index_url
    settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    settings
  end
end
