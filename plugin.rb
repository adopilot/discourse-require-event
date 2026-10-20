# frozen_string_literal: true

# name: discourse-require-event
# about: Requires every new topic in selected categories to contain an event (built-in Discourse Events)
# version: 0.1.0
# authors: Robot d.o.o.
# url: https://github.com/adopilot/discourse-require-event
# required_version: 2026.10.0

enabled_site_setting :require_event_enabled

after_initialize do
  module ::DiscourseRequireEvent
    EVENT_MARKER = /\[event[\s\]]/i

    def self.category_ids
      SiteSetting.require_event_categories.to_s.split("|").map(&:to_i)
    end

    def self.has_event?(raw)
      raw.to_s.match?(EVENT_MARKER)
    end
  end

  # Only the first post of a topic in a configured category is checked.
  # New topics must contain an [event] block; on edit, an existing event
  # cannot be removed. Older topics without an event can still be edited.
  validate(:post, :require_event_in_category) do
    return if !SiteSetting.require_event_enabled
    return if topic.nil? || !is_first_post?
    return if DiscourseRequireEvent.category_ids.exclude?(topic.category_id)
    return if acting_user&.id == Discourse::SYSTEM_USER_ID
    return if DiscourseRequireEvent.has_event?(raw)

    if new_record?
      errors.add(:base, I18n.t("require_event.missing_event"))
    elsif will_save_change_to_raw? && DiscourseRequireEvent.has_event?(raw_in_database)
      errors.add(:base, I18n.t("require_event.cannot_remove_event"))
    end
  end
end
