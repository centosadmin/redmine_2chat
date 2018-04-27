module Redmine2chat::Patches
  module IssuePatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable

        has_many :chat_messages, through: :chat, source: :messages
        has_one :chat, class_name: 'IssueChat'

        before_save :set_need_to_close, :reset_need_to_close
        before_destroy :close_chat

        def set_need_to_close
          if closing? && chat.present?
            chat.update need_to_close_at: 2.weeks.from_now,
                        last_notification_at: (1.week.from_now - 12.hours)

          end
        end

        def reset_need_to_close
          if reopening? && chat.present?
            chat.update need_to_close_at: nil,
                        last_notification_at: nil
          end
        end
      end
    end
  end
end
Issue.send(:include, Redmine2chat::Patches::IssuePatch)