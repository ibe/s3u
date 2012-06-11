class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :cn, :extDocId
  
  def extDocId
    self.extDocId = Devise::LdapAdapter.get_ldap_param(self.cn, "employeeID")
  end
  
  def prenameDoc
    gn = Devise::LdapAdapter.get_ldap_param(self.cn, "givenName")
    gn.first
  end
  
  def surnameDoc
    sn = Devise::LdapAdapter.get_ldap_param(self.cn, "sn")
    sn.first
  end

  def mailDoc
    ml = Devise::LdapAdapter.get_ldap_param(self.cn, "mail")
    ml.first.downcase!
  end
end
