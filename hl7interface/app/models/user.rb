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
    membership.include?(S3uLmuHl7interface::Application.config.administrator_group)
  end
  
  def permissions
    # get AD groups, the current user (i.e. self.cn) is member of
    membership = Devise::LdapAdapter.get_ldap_entry(self.cn)["memberOf"]
    group = Array.new
    membership.each do |m|
      # intersect AD groups with groups defined in this application
      # (latter should be subset of the former)
      group.concat(Group.where(:distinguishedName => m.downcase))
    end
    permissions = Array.new
    group.each do |g|
      # get permissions of intersection
      permissions.concat(g.permissions)
    end
    conditions = Array.new
    permissions.each do |p|
      subconditions = Array.new
      # build sql-where statement of permissions
      if p.dataSource != "ALL"
        subconditions.push("dataSource = '" + p.dataSource + "'")
      end
      if p.segment != "ALL"
        subconditions.push("segment = '" + p.segment + "'")
      end
      if p.composite != -1
        subconditions.push("composite = " + p.composite.to_s)
      end
      if p.subcomposite != -1
        subconditions.push("subcomposite = " + p.subcomposite.to_s)
      end
      if p.subsubcomposite != -1
        subconditions.push("subsubcomposite = " + p.subsubcomposite.to_s)
      end
      if p.value != ""
        subconditions.push("value = '" + p.value + "'")
      end
      if subconditions.length != 0
        conditions.push("(" + subconditions.join(' AND ') + ")")
      end
    end
    # check if we had any permissions at all:
    if permissions.length != 0
      # ... if yes, join conditions together with "OR" statement
      conditions.join(' AND ')
    else
      # ... if no, return 0 which results in "where (0)" therefor
      # displaying no messages at all
      0
    end
  end
end
