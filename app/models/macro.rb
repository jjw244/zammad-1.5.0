# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Macro < ApplicationModel
  include NotifiesClients
  include LatestChangeObserved

  store     :perform
  validates :name, presence: true
end
