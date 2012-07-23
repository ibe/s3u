class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :cn

  def admin?
    membership = Devise::LdapAdapter.get_ldap_entry(self.cn)["memberOf"]
    # example: this is the "master" group - i.e. users which this application
    #          will "recognize" as admins need to be member of this LDAP group
    # refers to config/initializers/s3u_lmu.rb
    membership.include?(S3uLmuWebrequest::Application.config.administrator_group)
  end
end
