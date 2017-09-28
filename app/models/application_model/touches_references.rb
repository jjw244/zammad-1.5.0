# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/
module ApplicationModel::TouchesReferences
  extend ActiveSupport::Concern

  # methods defined here are going to extend the class, not the instance of it
  class_methods do

=begin

touch references by params

  Model.touch_reference_by_params(
    object: 'Ticket',
    o_id: 123,
  )

=end

    def touch_reference_by_params(data)

      object_class = Kernel.const_get(data[:object])
      object = object_class.lookup(id: data[:o_id])
      return if !object
      object.touch
    rescue => e
      logger.error e
    end
  end
end
