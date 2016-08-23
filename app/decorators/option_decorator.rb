class OptionDecorator < Draper::Decorator

  def name
    context[:user].internal? && object.client ? "#{object.name} (#{object.client.name})" : object.name
  end

  def id
    object.id
  end
end