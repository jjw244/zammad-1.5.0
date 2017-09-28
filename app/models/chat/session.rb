class Chat::Session < ApplicationModel
  before_create :generate_session_id
  store         :preferences

  def generate_session_id
    self.session_id = Digest::MD5.hexdigest(Time.zone.now.to_s + rand(99_999_999_999_999).to_s)
  end

  def add_recipient(client_id, store = false)
    if !preferences[:participants]
      preferences[:participants] = []
    end
    return preferences[:participants] if preferences[:participants].include?(client_id)
    preferences[:participants].push client_id
    if store
      save
    end
    preferences[:participants]
  end

  def recipients_active?
    return true if !preferences
    return true if !preferences[:participants]
    count = 0
    preferences[:participants].each { |client_id|
      next if !Sessions.session_exists?(client_id)
      count += 1
    }
    return true if count >= 2
    false
  end

  def send_to_recipients(message, ignore_client_id = nil)
    preferences[:participants].each { |local_client_id|
      next if local_client_id == ignore_client_id
      Sessions.send(local_client_id, message)
    }
    true
  end

  def position
    return if state != 'waiting'
    position = 0
    Chat::Session.where(state: 'waiting').order(created_at: :asc).each { |chat_session|
      position += 1
      break if chat_session.id == id
    }
    position
  end

  def self.messages_by_session_id(session_id)
    chat_session = Chat::Session.find_by(session_id: session_id)
    return if !chat_session
    session_attributes = []
    Chat::Message.where(chat_session_id: chat_session.id).order(created_at: :asc).each { |message|
      session_attributes.push message.attributes
    }
    session_attributes
  end

  def self.active_chats_by_user_id(user_id)
    actice_sessions = []
    Chat::Session.where(state: 'running', user_id: user_id).order(created_at: :asc).each { |session|
      session_attributes = session.attributes
      session_attributes['messages'] = []
      Chat::Message.where(chat_session_id: session.id).order(created_at: :asc).each { |message|
        session_attributes['messages'].push message.attributes
      }
      actice_sessions.push session_attributes
    }
    actice_sessions
  end
end