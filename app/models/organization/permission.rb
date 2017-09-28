# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Organization
  module Permission

=begin

check if user has access to user

  user   = Organization.find(123)
  result = organization.permission(type: 'rw', current_user: User.find(123))

returns

  result = true|false

=end

    def permission (data)

      # check customer
      if data[:current_user].permissions?('ticket.customer')

        # access ok if its own organization
        return false if data[:type] != 'ro'
        return false if !data[:current_user].organization_id
        return true if id == data[:current_user].organization_id

        # no access
        return false
      end

      # check agent
      return true if data[:current_user].permissions?('admin')
      return true if data[:current_user].permissions?('ticket.agent')
      false
    end
  end
end
