# ABOUTME: Discourse plugin that gates closed topics behind login for anonymous users.
# ABOUTME: Uses Guardian extension to deny anonymous access to closed topics.

# frozen_string_literal: true

# name: discourse-closed-topic-gate
# about: Requires login to view closed topics
# version: 0.1.0
# authors: Fly.io

enabled_site_setting :closed_topic_gate_enabled

after_initialize do
  module ::ClosedTopicGate
    module GuardianExtension
      def can_see_topic?(topic, hide_deleted = true)
        return super unless SiteSetting.closed_topic_gate_enabled
        return super unless topic&.closed?

        if SiteSetting.closed_topic_gate_demo_mode
          # Demo mode: staff see the gated experience, everyone else normal
          return false if is_staff?
        else
          # Production mode: anonymous users get gated
          return false if anonymous?
        end

        super
      end
    end
  end

  Guardian.prepend(::ClosedTopicGate::GuardianExtension)
end
